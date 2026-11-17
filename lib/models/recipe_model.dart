import 'package:cloud_firestore/cloud_firestore.dart';
class RecipeIngredient {
  final String ingredientId;
  final String ingredientName;
  final double quantity;
  final String unit;

  RecipeIngredient({
    required this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      ingredientId: map['ingredientId'] ?? '',
      ingredientName: map['ingredientName'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class RecipeModel {
  final String id;
  final String menuId;
  final String menuName;
  final List<RecipeIngredient> ingredients;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecipeModel({
    required this.id,
    required this.menuId,
    required this.menuName,
    required this.ingredients,
    this.createdAt,
    this.updatedAt,
  });

  factory RecipeModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    final ingredientList = map['ingredients'] as List<dynamic>? ?? [];

    return RecipeModel(
      id: documentId,
      menuId: map['menuId'] ?? '',
      menuName: map['menuName'] ?? '',
      ingredients: ingredientList
          .map((item) => RecipeIngredient.fromMap(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'menuName': menuName,
      'ingredients': ingredients.map((item) => item.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
