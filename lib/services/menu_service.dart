
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/menu_model.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _menuCollection {
    return _firestore.collection('menus');
  }

  // Mengambil seluruh menu secara realtime.
  Stream<List<MenuModel>> getAllMenus() {
    return _menuCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        return MenuModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil menu yang tersedia saja.
  Stream<List<MenuModel>> getAvailableMenus() {
    return _menuCollection
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return MenuModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil menu berdasarkan kategori.
  Stream<List<MenuModel>> getMenusByCategory(String category) {
    return _menuCollection
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return MenuModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil satu menu berdasarkan ID.
  Future<MenuModel?> getMenuById(String menuId) async {
    final document = await _menuCollection.doc(menuId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return MenuModel.fromMap(
      document.id,
      document.data()!,
    );
  }
}
