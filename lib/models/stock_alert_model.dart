
import 'package:cloud_firestore/cloud_firestore.dart';

class StockAlertModel {
  final String id;
  final String itemId;
  final String itemName;
  final String location;
  final double currentStock;
  final double minimumStock;
  final String unit;
  final String status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  StockAlertModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.location,
    required this.currentStock,
    required this.minimumStock,
    required this.unit,
    required this.status,
    this.createdAt,
    this.resolvedAt,
  });

  // Mengubah data Firestore menjadi StockAlertModel.
  factory StockAlertModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return StockAlertModel(
      id: documentId,
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      location: map['location'] ?? '',
      currentStock: (map['currentStock'] as num?)?.toDouble() ?? 0,
      minimumStock: (map['minimumStock'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] ?? '',
      status: map['status'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Mengubah StockAlertModel menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'location': location,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'unit': unit,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'resolvedAt': resolvedAt,
    };
  }

  // Memeriksa status peringatan stok.
  bool get isActive => status == 'active';

  bool get isResolved => status == 'resolved';
}
