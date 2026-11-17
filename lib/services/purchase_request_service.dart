
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/purchase_request_model.dart';

class PurchaseRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-southeast2');

  CollectionReference<Map<String, dynamic>> get _requestCollection =>
      _firestore.collection('purchase_requests');

  Future<String> createPurchaseRequest({
    required String itemId,
    required String itemName,
    required double quantity,
    required String unit,
    required String reason,
  }) async {
    if (!quantity.isFinite || quantity <= 0) {
      throw Exception('Jumlah pembelian harus lebih dari 0.');
    }

    final callable = _functions.httpsCallable('createPurchaseRequest');

    final result = await callable.call<Map<String, dynamic>>({
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'reason': reason,
    });

    final data = result.data;

    if (data['success'] != true || data['requestId'] == null) {
      throw Exception('Pengajuan pembelian gagal dibuat.');
    }

    return data['requestId'] as String;
  }

  Stream<List<PurchaseRequestModel>> getAllRequests() {
    return _requestCollection.snapshots().map((snapshot) {
      final requests = snapshot.docs
          .map((document) => PurchaseRequestModel.fromMap(
                document.id,
                document.data(),
              ))
          .toList();

      requests.sort((a, b) =>
          (b.createdAt ?? DateTime(2000))
              .compareTo(a.createdAt ?? DateTime(2000)));

      return requests;
    });
  }

  Stream<List<PurchaseRequestModel>> getRequestsByStatus(String status) {
    return _requestCollection
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((document) => PurchaseRequestModel.fromMap(
                document.id,
                document.data(),
              ))
          .toList();

      requests.sort((a, b) =>
          (b.createdAt ?? DateTime(2000))
              .compareTo(a.createdAt ?? DateTime(2000)));

      return requests;
    });
  }

  Stream<List<PurchaseRequestModel>> getRequestsByUser(String userId) {
    return _requestCollection
        .where('requestedBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((document) => PurchaseRequestModel.fromMap(
                document.id,
                document.data(),
              ))
          .toList();

      requests.sort((a, b) =>
          (b.createdAt ?? DateTime(2000))
              .compareTo(a.createdAt ?? DateTime(2000)));

      return requests;
    });
  }

  Future<PurchaseRequestModel?> getRequestById(String requestId) async {
    final document = await _requestCollection.doc(requestId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return PurchaseRequestModel.fromMap(
      document.id,
      document.data()!,
    );
  }
}
