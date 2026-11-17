
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _recipeCollection {
    return _firestore.collection('recipes');
  }

  // Mengambil seluruh resep secara realtime.
  Stream<List<RecipeModel>> getAllRecipes() {
    return _recipeCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        return RecipeModel.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  // Mengambil resep berdasarkan ID menu.
  Future<RecipeModel?> getRecipeByMenuId(String menuId) async {
    final document = await _recipeCollection.doc(menuId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return RecipeModel.fromMap(
      document.id,
      document.data()!,
    );
  }
}
