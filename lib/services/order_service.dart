
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/order_model.dart';

// Hasil ketika pesanan berhasil dibuat.
class OrderCreationResult {
  final String orderId;
  final String orderNumber;
  final double totalAmount;

  OrderCreationResult({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
  });
}

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-southeast2');

  CollectionReference<Map<String, dynamic>> get _orderCollection {
    return _firestore.collection('orders');
  }

  // Membuat pesanan melalui Cloud Functions.
  Future<OrderCreationResult> createOrder({
    required List<OrderItem> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('Pesanan tidak boleh kosong.');
    }

    for (final item in items) {
      if (item.quantity <= 0) {
        throw Exception('Jumlah pesanan harus lebih dari 0.');
      }
    }

    final callable = _functions.httpsCallable('createOrder');

    final result = await callable.call<Map<String, dynamic>>({
      'items': items.map((item) {
        return {
          'menuId': item.menuId,
          'quantity': item.quantity,
        };
      }).toList(),
    });

    final data = result.data;

    if (data['success'] != true ||
        data['orderId'] is! String ||
        data['orderNumber'] is! String ||
        data['totalAmount'] is! num) {
      throw Exception('Respons pembuatan pesanan tidak valid.');
    }

    return OrderCreationResult(
      orderId: data['orderId'] as String,
      orderNumber: data['orderNumber'] as String,
      totalAmount: (data['totalAmount'] as num).toDouble(),
    );
  }

  // Mengambil seluruh pesanan secara realtime.
  Stream<List<OrderModel>> getAllOrders() {
    return _orderCollection.snapshots().map((snapshot) {
      final orders = snapshot.docs.map((document) {
        return OrderModel.fromMap(document.id, document.data());
      }).toList();

      orders.sort((a, b) {
        return (b.createdAt ?? DateTime(2000))
            .compareTo(a.createdAt ?? DateTime(2000));
      });

      return orders;
    });
  }

  // Mengambil pesanan yang sudah selesai.
  Stream<List<OrderModel>> getCompletedOrders() {
    return _getOrdersByStatus('selesai');
  }

  // Mengambil pesanan yang belum selesai.
  Stream<List<OrderModel>> getUnfinishedOrders() {
    return _orderCollection
        .where('status', whereIn: ['menunggu', 'diproses'])
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((document) {
        return OrderModel.fromMap(document.id, document.data());
      }).toList();

      orders.sort((a, b) {
        return (b.createdAt ?? DateTime(2000))
            .compareTo(a.createdAt ?? DateTime(2000));
      });

      return orders;
    });
  }

  // Mengambil pesanan berdasarkan status tertentu.
  Stream<List<OrderModel>> _getOrdersByStatus(String status) {
    return _orderCollection
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((document) {
        return OrderModel.fromMap(document.id, document.data());
      }).toList();

      orders.sort((a, b) {
        return (b.createdAt ?? DateTime(2000))
            .compareTo(a.createdAt ?? DateTime(2000));
      });

      return orders;
    });
  }

  // Mengambil detail satu pesanan.
  Future<OrderModel?> getOrderById(String orderId) async {
    final document = await _orderCollection.doc(orderId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return OrderModel.fromMap(document.id, document.data()!);
  }
}
