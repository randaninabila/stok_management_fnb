
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_model.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _inventoryCollection {
    return _firestore.collection('inventory');
  }

  // Mengambil seluruh data inventory secara realtime.
  Stream<List<InventoryModel>> getAllInventory() {
    return _inventoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        return InventoryModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil inventory berdasarkan lokasi.
  Stream<List<InventoryModel>> getInventoryByLocation(
    String location,
  ) {
    return _inventoryCollection
        .where('location', isEqualTo: location)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return InventoryModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil satu data inventory berdasarkan ID dokumen.
  Future<InventoryModel?> getInventoryById(String inventoryId) async {
    final document = await _inventoryCollection.doc(inventoryId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return InventoryModel.fromMap(
      document.id,
      document.data()!,
    );
  }
}
