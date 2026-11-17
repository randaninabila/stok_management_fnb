
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String menuId;
  final String menuName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String productType;
  final String unit;
  final List<Map<String, dynamic>> recipeSnapshot;

  OrderItem({
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.productType,
    required this.unit,
    required this.recipeSnapshot,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuId: map['menuId'] ?? '',
      menuName: map['menuName'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      productType: map['productType'] ?? '',
      unit: map['unit'] ?? '',
      recipeSnapshot: (map['recipeSnapshot'] as List<dynamic>? ?? [])
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'menuName': menuName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'productType': productType,
      'unit': unit,
      'recipeSnapshot': recipeSnapshot,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String cashierId;
  final String cashierName;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final bool stockDeducted;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.cashierId,
    required this.cashierName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.stockDeducted,
    this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return OrderModel(
      id: documentId,
      orderNumber: map['orderNumber'] ?? '',
      cashierId: map['cashierId'] ?? '',
      cashierName: map['cashierName'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map(
            (item) => OrderItem.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
      status: map['status'] ?? 'menunggu',
      stockDeducted: map['stockDeducted'] == true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'stockDeducted': stockDeducted,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'completedAt': completedAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isCompleted => status == 'selesai';

  bool get isCancelled => status == 'dibatalkan';

  bool get isUnfinished =>
      status == 'menunggu' || status == 'diproses';
}
