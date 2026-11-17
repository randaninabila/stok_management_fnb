
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stock_movement_model.dart';

class StockMovementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _movementCollection {
    return _firestore.collection('stock_movements');
  }

  // Mengambil seluruh riwayat pergerakan stok.
  Stream<List<StockMovementModel>> getAllMovements() {
    return _movementCollection.snapshots().map((snapshot) {
      final movements = snapshot.docs.map((document) {
        return StockMovementModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();

      movements.sort((a, b) {
        return (b.createdAt ?? DateTime(2000))
            .compareTo(a.createdAt ?? DateTime(2000));
      });

      return movements;
    });
  }

  // Mengambil riwayat berdasarkan jenis pergerakan.
  Stream<List<StockMovementModel>> getMovementsByType(
    String movementType,
  ) {
    return _movementCollection
        .where('movementType', isEqualTo: movementType)
        .snapshots()
        .map((snapshot) {
      final movements = snapshot.docs.map((document) {
        return StockMovementModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();

      movements.sort((a, b) {
        return (b.createdAt ?? DateTime(2000))
            .compareTo(a.createdAt ?? DateTime(2000));
      });

      return movements;
    });
  }

  // Mengambil riwayat berdasarkan ID barang.
  Stream<List<StockMovementModel>> getMovementsByItem(
    String itemId,
  ) {
    return _movementCollection
        .where('itemId', isEqualTo: itemId)
        .snapshots()
        .map((snapshot) {
      final movements = snapshot.docs.map((document) {
        return StockMovementModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();

      movements.sort((a, b) {
        return (b.createdAt ?? DateTime(2000))
            .compareTo(a.createdAt ?? DateTime(2000));
      });

      return movements;
    });
  }
}
