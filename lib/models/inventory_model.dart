
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryModel {
  final String id;
  final String itemId;
  final String itemName;
  final String itemType;
  final String location;
  final double quantity;
  final double minimumStock;
  final String unit;
  final DateTime? updatedAt;

  InventoryModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.location,
    required this.quantity,
    required this.minimumStock,
    required this.unit,
    this.updatedAt,
  });

  factory InventoryModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return InventoryModel(
      id: documentId,
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      itemType: map['itemType'] ?? '',
      location: map['location'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      minimumStock: (map['minimumStock'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] ?? '',
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemType': itemType,
      'location': location,
      'quantity': quantity,
      'minimumStock': minimumStock,
      'unit': unit,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isLowStock => quantity <= minimumStock;

  double get remainingStock =>
    (quantity - minimumStock).clamp(0.0, double.infinity);
}
