
import { initializeApp } from "firebase-admin/app";
import {
  getFirestore,
  FieldValue,
  DocumentReference,
  DocumentSnapshot,
} from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";

initializeApp();

const db = getFirestore();
const REGION = "asia-southeast2";

type CallableData = Record<string, any>;

type StockChange = {
  itemId: string;
  itemName: string;
  location?: string;
  fromLocation?: string | null;
  toLocation?: string | null;
  quantity: number;
  unit: string;
  movementType: string;
  performedBy: string;
  performedByName: string;
  reason?: string;
  notes?: string;
  referenceId?: string;
};

type Deduction = {
  itemId: string;
  itemName: string;
  quantity: number;
  unit: string;
  location: string;
};

function locationSlug(location: string): string {
  if (location === "Gudang Utama") return "gudang_utama";
  if (location === "Dapur") return "dapur";

  throw new HttpsError("invalid-argument", "Lokasi tidak valid.");
}

function inventoryRef(itemId: string, location: string) {
  validateText(itemId, "Item ID");

  return db.collection("inventory").doc(
    `${itemId}_${locationSlug(location)}`
  );
}

function alertRef(itemId: string, location: string) {
  validateText(itemId, "Item ID");

  return db.collection("stock_alerts").doc(
    `${itemId}_${locationSlug(location)}`
  );
}

function validateQuantity(quantity: number) {
  if (
    typeof quantity !== "number" ||
    !Number.isFinite(quantity) ||
    quantity <= 0
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Jumlah harus berupa angka lebih dari 0."
    );
  }
}

function validateText(value: string, field: string) {
  if (
    typeof value !== "string" ||
    value.trim() === ""
  ) {
    throw new HttpsError(
      "invalid-argument",
      `${field} wajib diisi.`
    );
  }
}

function validateOptionalText(value: unknown, field: string) {
  if (value !== undefined && typeof value !== "string") {
    throw new HttpsError(
      "invalid-argument",
      `${field} harus berupa teks.`
    );
  }
}


function validateStockData(
  stock: CallableData,
  expectedItemId?: string,
  expectedUnit?: string
) {
  const quantity = Number(stock.quantity);
  const minimumStock = Number(stock.minimumStock ?? 0);

  if (!Number.isFinite(quantity) || quantity < 0) {
    throw new HttpsError(
      "failed-precondition",
      "Data jumlah stok tidak valid."
    );
  }

  if (!Number.isFinite(minimumStock) || minimumStock < 0) {
    throw new HttpsError(
      "failed-precondition",
      "Data minimum stok tidak valid."
    );
  }

  if (
    expectedItemId !== undefined &&
    stock.itemId !== expectedItemId
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Identitas item stok tidak cocok."
    );
  }

  if (
    expectedUnit !== undefined &&
    stock.unit !== expectedUnit
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Satuan stok tidak cocok dengan data pesanan."
    );
  }

  validateText(stock.itemName, "Nama item stok");
  validateText(stock.unit, "Satuan stok");
}


async function requireRole(
  request: any,
  allowedRoles: string[]
) {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Silakan login terlebih dahulu."
    );
  }

  const uid = request.auth.uid;

  const userSnapshot = await db
    .collection("users")
    .doc(uid)
    .get();

  if (!userSnapshot.exists) {
    throw new HttpsError(
      "permission-denied",
      "Profil pengguna tidak ditemukan."
    );
  }

  const user = userSnapshot.data()!;

  if (user.isActive !== true) {
  throw new HttpsError(
    "permission-denied",
    "Akun pengguna tidak aktif."
  );
  }

  if (!allowedRoles.includes(user.role)) {
    throw new HttpsError(
      "permission-denied",
      "Anda tidak memiliki izin untuk melakukan tindakan ini."
    );
  }

  return {
    uid,
    name: user.name ?? "",
    role: user.role,
  };
}


// ======================================================
// 1. MEMBUAT PESANAN BARU
// ======================================================


export const createOrder = onCall(
  { region: REGION },
  async (request) => {
    const actor = await requireRole(request, ["kasir"]);

    const { items } = request.data ?? {};

    if (!Array.isArray(items) || items.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "Pesanan tidak boleh kosong."
      );
    }

    if (items.length > 50) {
      throw new HttpsError(
        "invalid-argument",
        "Maksimal 50 item dalam satu pesanan."
      );
    }

    // Validasi input dari aplikasi kasir.
    const requestedItems: CallableData[] = items.map(
      (item: CallableData) => {
        if (!item || typeof item !== "object") {
          throw new HttpsError(
            "invalid-argument",
            "Format item pesanan tidak valid."
          );
        }

        validateText(item.menuId, "Menu ID");

        if (
          typeof item.quantity !== "number" ||
          !Number.isInteger(item.quantity) ||
          item.quantity <= 0
        ) {
          throw new HttpsError(
            "invalid-argument",
            "Jumlah pesanan harus berupa bilangan bulat positif."
          );
        }

        return {
          menuId: item.menuId,
          quantity: item.quantity,
        };
      }
    );

    // Buat ID dokumen pesanan dari backend.
    const orderRef = db.collection("orders").doc();

    // Format tanggal menggunakan zona waktu Indonesia.
    const dateParts = new Intl.DateTimeFormat("en-GB", {
      timeZone: "Asia/Jakarta",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    }).formatToParts(new Date());

    const dateValues: Record<string, string> = {};

    for (const part of dateParts) {
      if (part.type !== "literal") {
        dateValues[part.type] = part.value;
      }
    }

    const orderDate =
      `${dateValues.year}${dateValues.month}${dateValues.day}`;

    const orderNumber =
      `NT-${orderDate}-${orderRef.id.substring(0, 8).toUpperCase()}`;

    return db.runTransaction(async (transaction) => {
      // Baca seluruh dokumen menu terlebih dahulu.
      const menuSnapshots: DocumentSnapshot[] = [];

      for (const item of requestedItems) {
        const menuRef = db.collection("menus").doc(item.menuId);
        const menuSnapshot = await transaction.get(menuRef);

        if (!menuSnapshot.exists) {
          throw new HttpsError(
            "not-found",
            `Menu dengan ID ${item.menuId} tidak ditemukan.`
          );
        }

        menuSnapshots.push(menuSnapshot);
      }

      const preparedItems: CallableData[] = [];
      let totalAmount = 0;

      // Baca resep dan susun snapshot sebelum melakukan penulisan.
      for (
        let index = 0;
        index < requestedItems.length;
        index++
      ) {
        const requestedItem = requestedItems[index];
        const menuData = menuSnapshots[index].data()!;

        if (menuData.isAvailable !== true) {
          throw new HttpsError(
            "failed-precondition",
            `Menu ${menuData.name ?? requestedItem.menuId} sedang tidak tersedia.`
          );
        }

        validateText(menuData.name, "Nama menu");
        validateText(menuData.unit, `Satuan menu ${menuData.name}`);

        const price = Number(menuData.price);

        if (!Number.isFinite(price) || price < 0) {
          throw new HttpsError(
            "failed-precondition",
            `Harga menu ${menuData.name} tidak valid.`
          );
        }

        const productType = menuData.productType;
        let recipeSnapshot: CallableData[] = [];

        if (productType === "made_to_order") {
          validateText(
            menuData.recipeId,
            `ID resep ${menuData.name}`
          );

          const recipeRef = db
            .collection("recipes")
            .doc(menuData.recipeId);

          const recipeDoc = await transaction.get(recipeRef);

          if (!recipeDoc.exists) {
            throw new HttpsError(
              "failed-precondition",
              `Resep ${menuData.name} tidak ditemukan.`
            );
          }

          const recipeData = recipeDoc.data()!;
          const ingredients = recipeData.ingredients;

          if (
            !Array.isArray(ingredients) ||
            ingredients.length === 0
          ) {
            throw new HttpsError(
              "failed-precondition",
              `Resep ${menuData.name} belum memiliki bahan.`
            );
          }

          recipeSnapshot = ingredients.map(
            (ingredient: CallableData) => {
              if (!ingredient || typeof ingredient !== "object") {
                throw new HttpsError(
                  "failed-precondition",
                  "Format bahan dalam resep tidak valid."
                );
              }

              validateText(
                ingredient.ingredientId,
                "Ingredient ID"
              );
              validateText(
                ingredient.ingredientName,
                "Nama bahan"
              );
              validateText(
                ingredient.unit,
                "Satuan bahan"
              );

              const quantity = Number(ingredient.quantity);

              if (
                !Number.isFinite(quantity) ||
                quantity <= 0
              ) {
                throw new HttpsError(
                  "failed-precondition",
                  "Jumlah bahan dalam resep tidak valid."
                );
              }

              return {
                ingredientId: ingredient.ingredientId,
                ingredientName: ingredient.ingredientName,
                quantity,
                unit: ingredient.unit,
              };
            }
          );
        } else if (productType !== "finished_goods") {
          throw new HttpsError(
            "failed-precondition",
            `Jenis produk ${menuData.name} tidak valid.`
          );
        }

        const quantity = requestedItem.quantity;
        const subtotal = price * quantity;

        preparedItems.push({
          menuId: requestedItem.menuId,
          menuName: menuData.name,
          quantity,
          unitPrice: price,
          subtotal,
          productType,
          unit: menuData.unit,
          recipeSnapshot,
        });


        totalAmount += subtotal;
      }

      // Simpan pesanan setelah seluruh data berhasil divalidasi.
      transaction.set(orderRef, {
        orderNumber,
        cashierId: actor.uid,
        cashierName: actor.name,
        items: preparedItems,
        totalAmount,
        status: "menunggu",
        stockDeducted: false,
        createdAt: FieldValue.serverTimestamp(),
        completedAt: null,
        updatedAt: FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        orderId: orderRef.id,
        orderNumber,
        totalAmount,
        message: "Pesanan berhasil dibuat.",
      };
    });
  }
);


// ======================================================
// PENCATATAN PERGERAKAN STOK
// ======================================================

function addMovement(
  transaction: FirebaseFirestore.Transaction,
  data: StockChange
) {
  const ref = db.collection("stock_movements").doc();

  transaction.set(ref, {
    itemId: data.itemId,
    itemName: data.itemName,
    movementType: data.movementType,
    fromLocation: data.fromLocation ?? null,
    toLocation: data.toLocation ?? null,
    quantity: data.quantity,
    unit: data.unit,
    referenceId: data.referenceId ?? null,
    performedBy: data.performedBy,
    performedByName: data.performedByName,
    reason: data.reason ?? null,
    notes: data.notes ?? "",
    createdAt: FieldValue.serverTimestamp(),
  });
}

// ======================================================
// PENGELOLAAN ALERT STOK
// ======================================================

function updateAlert(
  transaction: FirebaseFirestore.Transaction,
  ref: DocumentReference,
  item: CallableData,
  location: string,
  newQuantity: number,
  alertSnapshot: DocumentSnapshot
) {
  const minimumStock = Number(item.minimumStock ?? 0);
  const isLow = newQuantity <= minimumStock;

  if (isLow) {
    const wasActive =
      alertSnapshot.exists &&
      alertSnapshot.data()?.status === "active";

    const alertData: CallableData = {
      itemId: item.itemId,
      itemName: item.itemName,
      location,
      currentStock: newQuantity,
      minimumStock,
      unit: item.unit,
      status: "active",
      resolvedAt: null,
    };

    // Waktu awal alert hanya dibuat saat alert baru
    // atau ketika alert resolved aktif kembali.
    if (!wasActive) {
      alertData.createdAt = FieldValue.serverTimestamp();
    }

    transaction.set(ref, alertData, { merge: true });
    return;
  }

  // Jangan membuat dokumen alert resolved jika
  // sebelumnya belum pernah ada alert.
  if (
    alertSnapshot.exists &&
    alertSnapshot.data()?.status === "active"
  ) {
    transaction.set(
      ref,
      {
        currentStock: newQuantity,
        minimumStock,
        status: "resolved",
        resolvedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }
}

// ======================================================
// 1. MENYELESAIKAN PESANAN DAN MENGURANGI STOK
// ======================================================


export const completeOrder = onCall(
  { region: REGION },
  async (request) => {
    const actor = await requireRole(request, ["kasir", "owner"]);

    const { orderId } = request.data ?? {};
    validateText(orderId, "Order ID");

    const orderRef = db.collection("orders").doc(orderId);

    return db.runTransaction(async (transaction) => {
      const orderSnapshot = await transaction.get(orderRef);

      if (!orderSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Pesanan tidak ditemukan."
        );
      }

      const order = orderSnapshot.data()!;

      if (order.status === "dibatalkan") {
        throw new HttpsError(
          "failed-precondition",
          "Pesanan yang dibatalkan tidak dapat diselesaikan."
        );
      }

      if (
        order.status === "selesai" &&
        order.stockDeducted === true
      ) {
        return {
          success: true,
          message: "Pesanan sudah diproses sebelumnya.",
        };
      }

      if (order.stockDeducted === true) {
        throw new HttpsError(
          "failed-precondition",
          "Stok pesanan ini sudah pernah dikurangi."
        );
      }

      if (
        !["menunggu", "diproses", "selesai"].includes(order.status)
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Status pesanan tidak valid."
        );
      }

      if (!Array.isArray(order.items) || order.items.length === 0) {
        throw new HttpsError(
          "failed-precondition",
          "Pesanan tidak memiliki item."
        );
      }

      const deductions: Record<string, Deduction> = {};

      for (const rawItem of order.items) {
        const orderItem: CallableData = rawItem;

        validateText(orderItem.menuId, "Menu ID");
        validateText(orderItem.menuName, "Nama menu");
        validateText(orderItem.productType, "Jenis produk");
        validateText(orderItem.unit, "Satuan menu");

        const menuQuantity = Number(orderItem.quantity);

        if (
          !Number.isInteger(menuQuantity) ||
          menuQuantity <= 0
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Jumlah item pesanan tidak valid."
          );
        }

        const recipe = orderItem.recipeSnapshot;

        if (orderItem.productType === "made_to_order") {
          if (!Array.isArray(recipe) || recipe.length === 0) {
            throw new HttpsError(
              "failed-precondition",
              `Snapshot resep ${orderItem.menuName} tidak tersedia.`
            );
          }

          for (const ingredient of recipe) {
            validateText(ingredient.ingredientId, "Ingredient ID");
            validateText(ingredient.ingredientName, "Nama bahan");
            validateText(ingredient.unit, "Satuan bahan");

            const ingredientQuantity = Number(ingredient.quantity);

            if (
              !Number.isFinite(ingredientQuantity) ||
              ingredientQuantity <= 0
            ) {
              throw new HttpsError(
                "failed-precondition",
                "Data resep pesanan tidak valid."
              );
            }

            const key = `${ingredient.ingredientId}|Dapur`;

            if (!deductions[key]) {
              deductions[key] = {
                itemId: ingredient.ingredientId,
                itemName: ingredient.ingredientName,
                quantity: 0,
                unit: ingredient.unit,
                location: "Dapur",
              };
            }

            if (deductions[key].unit !== ingredient.unit) {
              throw new HttpsError(
                "failed-precondition",
                "Satuan bahan dalam resep tidak konsisten."
              );
            }

            deductions[key].quantity +=
              ingredientQuantity * menuQuantity;
          }
        } else if (orderItem.productType === "finished_goods") {
          if (!Array.isArray(recipe) || recipe.length !== 0) {
            throw new HttpsError(
              "failed-precondition",
              "Barang jadi tidak boleh memiliki snapshot resep bahan baku."
            );
          }

          const key = `${orderItem.menuId}|Dapur`;

          if (!deductions[key]) {
            deductions[key] = {
              itemId: orderItem.menuId,
              itemName: orderItem.menuName,
              quantity: 0,
              unit: orderItem.unit,
              location: "Dapur",
            };
          }

          if (deductions[key].unit !== orderItem.unit) {
            throw new HttpsError(
              "failed-precondition",
              "Satuan barang jadi tidak konsisten."
            );
          }

          deductions[key].quantity += menuQuantity;
        } else {
          throw new HttpsError(
            "failed-precondition",
            `Jenis produk ${orderItem.menuName} tidak valid.`
          );
        }
      }

      const entries = Object.values(deductions);
      const snapshots = [];

      // Semua pembacaan dilakukan sebelum operasi tulis.
      for (const item of entries) {
        const stockRef = inventoryRef(item.itemId, item.location);
        const stockAlertRef = alertRef(item.itemId, item.location);

        const stockSnapshot = await transaction.get(stockRef);
        const alertSnapshot = await transaction.get(stockAlertRef);

        if (!stockSnapshot.exists) {
          throw new HttpsError(
            "failed-precondition",
            `Stok ${item.itemName} di Dapur tidak ditemukan.`
          );
        }

        const stock = stockSnapshot.data()!;

        validateStockData(
          stock,
          item.itemId,
          item.unit
        );

        snapshots.push({
          item,
          stockRef,
          stockAlertRef,
          stock,
          alertSnapshot,
        });
      }

      for (const entry of snapshots) {
        const newQuantity =
          Number(entry.stock.quantity) - entry.item.quantity;

        if (newQuantity < 0) {
          throw new HttpsError(
            "failed-precondition",
            `Stok ${entry.item.itemName} tidak mencukupi.`
          );
        }

        transaction.update(entry.stockRef, {
          quantity: newQuantity,
          updatedAt: FieldValue.serverTimestamp(),
        });

        updateAlert(
          transaction,
          entry.stockAlertRef,
          entry.stock,
          "Dapur",
          newQuantity,
          entry.alertSnapshot
        );

        addMovement(transaction, {
          itemId: entry.item.itemId,
          itemName: entry.item.itemName,
          fromLocation: "Dapur",
          quantity: entry.item.quantity,
          unit: entry.item.unit,
          movementType: "order_deduction",
          performedBy: actor.uid,
          performedByName: actor.name,
          referenceId: orderId,
        });
      }

      transaction.update(orderRef, {
        status: "selesai",
        stockDeducted: true,
        completedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        message: "Pesanan berhasil diselesaikan.",
      };
    });
  }
);


// ======================================================
// 2. BARANG TERBUANG
// ======================================================

export const recordWaste = onCall(
  { region: REGION },
  async (request) => {
    const actor = await requireRole(request, [
      "staf gudang",
      "staf dapur",
      "owner",
    ]);

    const {
      itemId,
      location,
      quantity,
      reason,
      notes = "",
    } = request.data ?? {};

    validateText(itemId, "Item ID");
    validateQuantity(quantity);
    validateText(reason, "Alasan");
    validateOptionalText(notes, "Catatan");

    const stockRef = inventoryRef(itemId, location);
    const stockAlertRef = alertRef(itemId, location);

    return db.runTransaction(async (transaction) => {
      const stockSnapshot = await transaction.get(stockRef);
      const alertSnapshot = await transaction.get(stockAlertRef);

      if (!stockSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Data stok tidak ditemukan."
        );
      }

      const stock = stockSnapshot.data()!;
      validateStockData(stock, itemId);

      const newQuantity = Number(stock.quantity) - quantity;

      if (newQuantity < 0) {
        throw new HttpsError(
          "failed-precondition",
          "Jumlah barang terbuang melebihi stok tersedia."
        );
      }

      transaction.update(stockRef, {
        quantity: newQuantity,
        updatedAt: FieldValue.serverTimestamp(),
      });

      updateAlert(
        transaction,
        stockAlertRef,
        stock,
        location,
        newQuantity,
        alertSnapshot
      );

      addMovement(transaction, {
        itemId,
        itemName: stock.itemName,
        fromLocation: location,
        quantity,
        unit: stock.unit,
        movementType: "waste",
        performedBy: actor.uid,
        performedByName: actor.name,
        reason,
        notes,
      });

      return {
        success: true,
        message: "Barang terbuang berhasil dicatat.",
      };
    });
  }
);

// ======================================================
// 3. PENYESUAIAN STOK
// ======================================================

export const adjustStock = onCall(
  { region: REGION },
  async (request) => {
    const actor = await requireRole(request, [
      "staf gudang",
      "owner",
    ]);

    const {
      itemId,
      location,
      quantity,
      direction,
      reason,
      notes = "",
    } = request.data ?? {};

    validateText(itemId, "Item ID");
    validateQuantity(quantity);
    validateText(reason, "Alasan");
    validateOptionalText(notes, "Catatan");

    if (!["in", "out"].includes(direction)) {
      throw new HttpsError(
        "invalid-argument",
        "Arah penyesuaian tidak valid."
      );
    }

    const stockRef = inventoryRef(itemId, location);
    const stockAlertRef = alertRef(itemId, location);

    return db.runTransaction(async (transaction) => {
      const stockSnapshot = await transaction.get(stockRef);
      const alertSnapshot = await transaction.get(stockAlertRef);

      if (!stockSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Data stok tidak ditemukan."
        );
      }

      const stock = stockSnapshot.data()!;
      validateStockData(stock, itemId);

      const newQuantity = direction === "in"
        ? Number(stock.quantity) + quantity
        : Number(stock.quantity) - quantity;

      if (newQuantity < 0) {
        throw new HttpsError(
          "failed-precondition",
          "Stok tidak mencukupi untuk penyesuaian keluar."
        );
      }

      transaction.update(stockRef, {
        quantity: newQuantity,
        updatedAt: FieldValue.serverTimestamp(),
      });

      updateAlert(
        transaction,
        stockAlertRef,
        stock,
        location,
        newQuantity,
        alertSnapshot
      );

      addMovement(transaction, {
        itemId,
        itemName: stock.itemName,
        toLocation: direction === "in" ? location : null,
        fromLocation: direction === "out" ? location : null,
        quantity,
        unit: stock.unit,
        movementType: "adjustment",
        performedBy: actor.uid,
        performedByName: actor.name,
        reason: `${direction}: ${reason}`,
        notes,
      });

      return {
        success: true,
        message: "Penyesuaian stok berhasil.",
      };
    });
  }
);

// ======================================================
// 4. TRANSFER STOK ANTARLOKASI
// ======================================================

export const transferStock = onCall(
  { region: REGION },
  async (request) => {
    const actor = await requireRole(request, [
      "staf gudang",
      "owner",
    ]);

    const {
      itemId,
      fromLocation,
      toLocation,
      quantity,
      notes = "",
    } = request.data ?? {};

    validateText(itemId, "Item ID");
    validateQuantity(quantity);
    validateOptionalText(notes, "Catatan");

    if (fromLocation === toLocation) {
      throw new HttpsError(
        "invalid-argument",
        "Lokasi asal dan tujuan tidak boleh sama."
      );
    }

    const sourceRef = inventoryRef(itemId, fromLocation);
    const destinationRef = inventoryRef(itemId, toLocation);
    const sourceAlertRef = alertRef(itemId, fromLocation);
    const destinationAlertRef = alertRef(itemId, toLocation);

    return db.runTransaction(async (transaction) => {
      const sourceSnapshot = await transaction.get(sourceRef);
      const destinationSnapshot = await transaction.get(destinationRef);
      const sourceAlertSnapshot = await transaction.get(sourceAlertRef);
      const destinationAlertSnapshot =
        await transaction.get(destinationAlertRef);

      if (!sourceSnapshot.exists || !destinationSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Data stok di salah satu lokasi tidak ditemukan."
        );
      }

      const source = sourceSnapshot.data()!;
      const destination = destinationSnapshot.data()!;

      validateStockData(source, itemId);
      validateStockData(destination, itemId);

      if (source.itemId !== destination.itemId) {
        throw new HttpsError(
          "failed-precondition",
          "Item stok pada kedua lokasi tidak cocok."
        );
      }

      if (source.unit !== destination.unit) {
        throw new HttpsError(
          "failed-precondition",
          "Satuan stok pada kedua lokasi tidak cocok."
        );
      }

      if (Number(source.quantity) < quantity) {
        throw new HttpsError(
          "failed-precondition",
          "Stok di lokasi asal tidak mencukupi."
        );
      }

      const sourceQuantity = Number(source.quantity) - quantity;
      const destinationQuantity =
        Number(destination.quantity) + quantity;

      transaction.update(sourceRef, {
        quantity: sourceQuantity,
        updatedAt: FieldValue.serverTimestamp(),
      });

      transaction.update(destinationRef, {
        quantity: destinationQuantity,
        updatedAt: FieldValue.serverTimestamp(),
      });

      updateAlert(
        transaction,
        sourceAlertRef,
        source,
        fromLocation,
        sourceQuantity,
        sourceAlertSnapshot
      );

      updateAlert(
        transaction,
        destinationAlertRef,
        destination,
        toLocation,
        destinationQuantity,
        destinationAlertSnapshot
      );

      addMovement(transaction, {
        itemId,
        itemName: source.itemName,
        movementType: "transfer",
        fromLocation,
        toLocation,
        quantity,
        unit: source.unit,
        performedBy: actor.uid,
        performedByName: actor.name,
        notes,
      });

      return {
        success: true,
        message: "Transfer stok berhasil.",
      };
    });
  }
);

// ======================================================
// 5. PERINGATAN STOK
// ======================================================

export const refreshStockAlert = onCall(
  { region: REGION },
  async (request) => {
    await requireRole(request, [
      "owner",
      "staf gudang",
      "staf dapur",
    ]);

    const { itemId, location } = request.data ?? {};

    validateText(itemId, "Item ID");

    const stockRef = inventoryRef(itemId, location);
    const stockAlertRef = alertRef(itemId, location);

    return db.runTransaction(async (transaction) => {
      const stockSnapshot = await transaction.get(stockRef);
      const alertSnapshot = await transaction.get(stockAlertRef);

      if (!stockSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Data stok tidak ditemukan."
        );
      }

      const stock = stockSnapshot.data()!;
      validateStockData(stock, itemId);

      const quantity = Number(stock.quantity);

      updateAlert(
        transaction,
        stockAlertRef,
        stock,
        location,
        quantity,
        alertSnapshot
      );

      return {
        success: true,
        isLowStock: quantity <= Number(stock.minimumStock ?? 0),
      };
    });
  }
);

// Menyelesaikan alert hanya jika stok aktual sudah aman.
export const resolveStockAlert = onCall(
  { region: REGION },
  async (request) => {
    await requireRole(request, ["owner"]);

    const { alertId } = request.data ?? {};
    validateText(alertId, "Alert ID");

    const stockAlertRef = db.collection("stock_alerts").doc(alertId);

    return db.runTransaction(async (transaction) => {
      const alertSnapshot = await transaction.get(stockAlertRef);

      if (!alertSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Peringatan tidak ditemukan."
        );
      }

      const alert = alertSnapshot.data()!;

      const stockRef = inventoryRef(
        alert.itemId,
        alert.location
      );

      const stockSnapshot = await transaction.get(stockRef);

      if (!stockSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Data stok terkait tidak ditemukan."
        );
      }

      const stock = stockSnapshot.data()!;
      validateStockData(stock, alert.itemId);

      if (
        Number(stock.quantity) <= Number(stock.minimumStock ?? 0)
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Stok masih berada pada batas minimum atau di bawahnya."
        );
      }

      transaction.set(
        stockAlertRef,
        {
          currentStock: Number(stock.quantity),
          minimumStock: Number(stock.minimumStock ?? 0),
          status: "resolved",
          resolvedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      return {
        success: true,
        message: "Peringatan berhasil diselesaikan.",
      };
    });
  }
);


// MEMBUAT PENGAJUAN PEMBELIAN
export const createPurchaseRequest = onCall(
  { region: REGION },
  async (request) => {
    const actor = await requireRole(request, ["staf gudang"]);

    const itemId = request.data?.itemId as string;
    const itemName = request.data?.itemName as string;
    const unit = request.data?.unit as string;
    const reason = request.data?.reason as string;

    validateText(itemId, "Item ID");
    validateText(itemName, "Nama item");
    validateText(unit, "Satuan");
    validateText(reason, "Alasan");

    const quantity = request.data?.quantity;

        if (
      typeof quantity !== "number" ||
      !Number.isFinite(quantity) ||
      quantity <= 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Jumlah pembelian harus berupa angka positif."
      );
    }

    const ingredientRef = db.collection("ingredients").doc(itemId);
    const requestRef = db.collection("purchase_requests").doc();

    return db.runTransaction(async (transaction) => {
      const ingredientSnapshot = await transaction.get(ingredientRef);

      if (!ingredientSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Bahan atau barang tidak ditemukan."
        );
      }

      const ingredient = ingredientSnapshot.data()!;

      if (ingredient.isActive !== true) {
        throw new HttpsError(
          "failed-precondition",
          "Bahan atau barang sudah tidak aktif."
        );
      }

      if (
        ingredient.name !== itemName ||
        ingredient.unit !== unit
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Data item tidak sesuai dengan database."
        );
      }

      const requestNumber =
        `PB-${Date.now()}-${requestRef.id.substring(0, 5).toUpperCase()}`;

      transaction.set(requestRef, {
        requestNumber,
        itemId,
        itemName: ingredient.name,
        quantity,
        unit: ingredient.unit,
        reason,
        status: "pending",
        requestedBy: actor.uid,
        requestedByName: actor.name,
        approvedBy: null,
        approvedByName: null,
        approvalNotes: null,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        approvedAt: null,
      });

      return {
        success: true,
        requestId: requestRef.id,
        requestNumber,
        message: "Pengajuan pembelian berhasil dibuat.",
      };
    });
  }
);

// ======================================================
// 6. PERMINTAAN PEMBELIAN
// ======================================================

export const approvePurchaseRequest = onCall(
  { region: REGION },
  async (request) => {
    const actor = await requireRole(request, ["owner"]);

    const {
      requestId,
      approvalNotes = "",
    } = request.data ?? {};

    validateText(requestId, "Request ID");
    validateOptionalText(approvalNotes, "Catatan persetujuan");

    const purchaseRef = db
      .collection("purchase_requests")
      .doc(requestId);

    return db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(purchaseRef);

      if (!snapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Permintaan pembelian tidak ditemukan."
        );
      }

      const purchase = snapshot.data()!;

      if (purchase.status !== "pending") {
        throw new HttpsError(
          "failed-precondition",
          "Permintaan ini bukan berstatus pending."
        );
      }

      transaction.update(purchaseRef, {
        status: "approved",
        approvedBy: actor.uid,
        approvedByName: actor.name,
        approvalNotes,
        approvedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        message: "Permintaan pembelian disetujui.",
      };
    });
  }
);

export const rejectPurchaseRequest = onCall(
  { region: REGION },
  async (request) => {
    const actor = await requireRole(request, ["owner"]);

    const {
      requestId,
      approvalNotes,
    } = request.data ?? {};

    validateText(requestId, "Request ID");
    validateText(approvalNotes, "Alasan penolakan");

    const purchaseRef = db
      .collection("purchase_requests")
      .doc(requestId);

    return db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(purchaseRef);

      if (!snapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Permintaan pembelian tidak ditemukan."
        );
      }

      const purchase = snapshot.data()!;

      if (purchase.status !== "pending") {
        throw new HttpsError(
          "failed-precondition",
          "Permintaan ini bukan berstatus pending."
        );
      }

      transaction.update(purchaseRef, {
        status: "rejected",
        approvedBy: actor.uid,
        approvedByName: actor.name,
        approvalNotes,
        updatedAt: FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        message: "Permintaan pembelian ditolak.",
      };
    });
  }
);

// ======================================================
// 7. MENERIMA BARANG PEMBELIAN
// ======================================================

export const receivePurchase = onCall(
  { region: REGION },
  async (request) => {
    const actor = await requireRole(request, [
      "staf gudang",
      "owner",
    ]);

    const { requestId } = request.data ?? {};
    validateText(requestId, "Request ID");

    const purchaseRef = db
      .collection("purchase_requests")
      .doc(requestId);

    return db.runTransaction(async (transaction) => {
      const purchaseSnapshot = await transaction.get(purchaseRef);

      if (!purchaseSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Permintaan pembelian tidak ditemukan."
        );
      }

      const purchase = purchaseSnapshot.data()!;

      if (purchase.status !== "approved") {
        throw new HttpsError(
          "failed-precondition",
          "Permintaan harus disetujui sebelum barang diterima."
        );
      }

      validateText(purchase.itemId, "Item ID");
      validateText(purchase.itemName, "Nama barang");
      validateText(purchase.unit, "Satuan");

      const quantity = Number(purchase.quantity);
      validateQuantity(quantity);

      const stockRef = inventoryRef(
        purchase.itemId,
        "Gudang Utama"
      );

      const stockAlertRef = alertRef(
        purchase.itemId,
        "Gudang Utama"
      );

      const stockSnapshot = await transaction.get(stockRef);
      const alertSnapshot = await transaction.get(stockAlertRef);

      if (!stockSnapshot.exists) {
        throw new HttpsError(
          "not-found",
          "Data stok Gudang Utama tidak ditemukan."
        );
      }

      const stock = stockSnapshot.data()!;
      validateStockData(stock, purchase.itemId, purchase.unit);

      if (stock.unit !== purchase.unit) {
        throw new HttpsError(
          "failed-precondition",
          "Satuan pembelian tidak sesuai dengan satuan stok."
        );
      }

      const newQuantity = Number(stock.quantity) + quantity;

      transaction.update(stockRef, {
        quantity: newQuantity,
        updatedAt: FieldValue.serverTimestamp(),
      });

      updateAlert(
        transaction,
        stockAlertRef,
        stock,
        "Gudang Utama",
        newQuantity,
        alertSnapshot
      );

      transaction.update(purchaseRef, {
        status: "received",
        updatedAt: FieldValue.serverTimestamp(),
      });

      addMovement(transaction, {
        itemId: purchase.itemId,
        itemName: purchase.itemName,
        toLocation: "Gudang Utama",
        quantity,
        unit: purchase.unit,
        movementType: "purchase_in",
        performedBy: actor.uid,
        performedByName: actor.name,
        referenceId: requestId,
      });

      return {
        success: true,
        message: "Barang diterima dan stok berhasil ditambahkan.",
      };
    });
  }
);
