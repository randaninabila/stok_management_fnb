
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ingredient_model.dart';

class IngredientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ingredientCollection {
    return _firestore.collection('ingredients');
  }

  // Mengambil seluruh bahan dan produk jadi.
  Stream<List<IngredientModel>> getAllIngredients() {
    return _ingredientCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        return IngredientModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil bahan dan produk yang masih aktif.
  Stream<List<IngredientModel>> getActiveIngredients() {
    return _ingredientCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return IngredientModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil data berdasarkan jenis item.
  Stream<List<IngredientModel>> getIngredientsByType(
    String itemType,
  ) {
    return _ingredientCollection
        .where('itemType', isEqualTo: itemType)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return IngredientModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil satu bahan berdasarkan ID.
  Future<IngredientModel?> getIngredientById(
    String ingredientId,
  ) async {
    final document =
        await _ingredientCollection.doc(ingredientId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return IngredientModel.fromMap(
      document.id,
      document.data()!,
    );
  }
}
