
import 'package:cloud_firestore/cloud_firestore.dart';

class StockMovementModel {
  final String id;
  final String itemId;
  final String itemName;
  final String movementType;
  final String? fromLocation;
  final String? toLocation;
  final double quantity;
  final String unit;
  final String? referenceId;
  final String performedBy;
  final String performedByName;
  final String? reason;
  final String? notes;
  final DateTime? createdAt;

  StockMovementModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.movementType,
    this.fromLocation,
    this.toLocation,
    required this.quantity,
    required this.unit,
    this.referenceId,
    required this.performedBy,
    required this.performedByName,
    this.reason,
    this.notes,
    this.createdAt,
  });

  // Mengubah data Firestore menjadi StockMovementModel.
  factory StockMovementModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return StockMovementModel(
      id: documentId,
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      movementType: map['movementType'] ?? '',
      fromLocation: map['fromLocation'] as String?,
      toLocation: map['toLocation'] as String?,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] ?? '',
      referenceId: map['referenceId'] as String?,
      performedBy: map['performedBy'] ?? '',
      performedByName: map['performedByName'] ?? '',
      reason: map['reason'] as String?,
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Mengubah StockMovementModel menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'movementType': movementType,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'quantity': quantity,
      'unit': unit,
      'referenceId': referenceId,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'reason': reason,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Pemeriksaan jenis pergerakan stok.
  bool get isOrderDeduction =>
      movementType == 'order_deduction';

  bool get isWaste =>
      movementType == 'waste';

  bool get isAdjustment =>
      movementType == 'adjustment';

  bool get isTransfer =>
      movementType == 'transfer';

  bool get isPurchaseIn =>
      movementType == 'purchase_in';
}
