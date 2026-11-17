
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stock_alert_model.dart';

class StockAlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _alertCollection {
    return _firestore.collection('stock_alerts');
  }

  // Mengambil seluruh peringatan stok.
  Stream<List<StockAlertModel>> getAllAlerts() {
    return _alertCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        return StockAlertModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil peringatan yang masih aktif.
  Stream<List<StockAlertModel>> getActiveAlerts() {
    return _alertCollection
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return StockAlertModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil peringatan berdasarkan lokasi.
  Stream<List<StockAlertModel>> getAlertsByLocation(
    String location,
  ) {
    return _alertCollection
        .where('location', isEqualTo: location)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return StockAlertModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }
}
