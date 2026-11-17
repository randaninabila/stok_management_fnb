
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseRequestModel {
  final String id;
  final String requestNumber;
  final String itemId;
  final String itemName;
  final double quantity;
  final String unit;
  final String reason;
  final String status;
  final String requestedBy;
  final String requestedByName;
  final String? approvedBy;
  final String? approvedByName;
  final String? approvalNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? approvedAt;

  PurchaseRequestModel({
    required this.id,
    required this.requestNumber,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.reason,
    required this.status,
    required this.requestedBy,
    required this.requestedByName,
    this.approvedBy,
    this.approvedByName,
    this.approvalNotes,
    this.createdAt,
    this.updatedAt,
    this.approvedAt,
  });

  // Mengubah data Firestore menjadi PurchaseRequestModel.
  factory PurchaseRequestModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return PurchaseRequestModel(
      id: documentId,
      requestNumber: map['requestNumber'] ?? '',
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? '',
      requestedBy: map['requestedBy'] ?? '',
      requestedByName: map['requestedByName'] ?? '',
      approvedBy: map['approvedBy'] as String?,
      approvedByName: map['approvedByName'] as String?,
      approvalNotes: map['approvalNotes'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      approvedAt: (map['approvedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Mengubah PurchaseRequestModel menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      'requestNumber': requestNumber,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'reason': reason,
      'status': status,
      'requestedBy': requestedBy,
      'requestedByName': requestedByName,
      'approvedBy': approvedBy,
      'approvedByName': approvedByName,
      'approvalNotes': approvalNotes,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'approvedAt': approvedAt,
    };
  }

  // Pemeriksaan status pengajuan.
  bool get isPending => status == 'pending';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  bool get isReceived => status == 'received';
}
