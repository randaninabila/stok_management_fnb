
import 'package:cloud_functions/cloud_functions.dart';

class StockTransactionService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-southeast2');

  // Memanggil Cloud Function dan mengembalikan hasilnya.
  Future<Map<String, dynamic>> _call(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    final callable = _functions.httpsCallable(functionName);

    final result = await callable.call<Map<String, dynamic>>(data);

    return result.data;
  }

  // Memastikan jumlah stok harus lebih dari 0.
  void _validateQuantity(double quantity) {
    if (!quantity.isFinite || quantity <= 0) {
    throw ArgumentError('Jumlah stok harus lebih dari 0.');
    }
  }

  // 1. Menyelesaikan pesanan sekaligus mengurangi stok satu kali.
  Future<Map<String, dynamic>> completeOrder({
    required String orderId,
  }) async {
    return _call('completeOrder', {
      'orderId': orderId,
    });
  }

  // 2. Mencatat barang terbuang sekaligus mengurangi stok.
  Future<Map<String, dynamic>> recordWaste({
    required String itemId,
    required String location,
    required double quantity,
    required String reason,
    String notes = '',
  }) async {
    _validateQuantity(quantity);

    return _call('recordWaste', {
      'itemId': itemId,
      'location': location,
      'quantity': quantity,
      'reason': reason,
      'notes': notes,
    });
  }

  // 3. Melakukan penyesuaian stok masuk atau keluar.
  Future<Map<String, dynamic>> adjustStock({
    required String itemId,
    required String location,
    required double quantity,
    required String direction,
    required String reason,
    String notes = '',
  }) async {
    _validateQuantity(quantity);

    if (direction != 'in' && direction != 'out') {
      throw ArgumentError(
        'Direction harus berupa in atau out.',
      );
    }

    return _call('adjustStock', {
      'itemId': itemId,
      'location': location,
      'quantity': quantity,
      'direction': direction,
      'reason': reason,
      'notes': notes,
    });
  }

  // 4. Memindahkan stok antarlokasi.
  Future<Map<String, dynamic>> transferStock({
    required String itemId,
    required String fromLocation,
    required String toLocation,
    required double quantity,
    String notes = '',
  }) async {
    _validateQuantity(quantity);

    if (fromLocation == toLocation) {
      throw ArgumentError(
        'Lokasi asal dan tujuan tidak boleh sama.',
      );
    }

    return _call('transferStock', {
      'itemId': itemId,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'quantity': quantity,
      'notes': notes,
    });
  }

  // 5. Memperbarui peringatan stok.
  // Backend akan menentukan apakah alert perlu dibuat atau diselesaikan.
  Future<Map<String, dynamic>> refreshStockAlert({
    required String itemId,
    required String location,
  }) async {
    return _call('refreshStockAlert', {
      'itemId': itemId,
      'location': location,
    });
  }

  // Menyelesaikan peringatan stok tertentu.
  Future<Map<String, dynamic>> resolveStockAlert({
    required String alertId,
  }) async {
    return _call('resolveStockAlert', {
      'alertId': alertId,
    });
  }

  // 6a. Menyetujui permintaan pembelian.
  // Persetujuan belum menambah stok.
  Future<Map<String, dynamic>> approvePurchaseRequest({
    required String requestId,
    String approvalNotes = '',
  }) async {
    return _call('approvePurchaseRequest', {
      'requestId': requestId,
      'approvalNotes': approvalNotes,
    });
  }

  // 6b. Menolak permintaan pembelian.
  Future<Map<String, dynamic>> rejectPurchaseRequest({
    required String requestId,
    required String approvalNotes,
  }) async {
    return _call('rejectPurchaseRequest', {
      'requestId': requestId,
      'approvalNotes': approvalNotes,
    });
  }

  // 6c. Mencatat barang yang sudah diterima.
  // Stok Gudang Utama bertambah setelah barang benar-benar diterima.
  Future<Map<String, dynamic>> receivePurchase({
    required String requestId,
  }) async {
    return _call('receivePurchase', {
      'requestId': requestId,
    });
  }
}
