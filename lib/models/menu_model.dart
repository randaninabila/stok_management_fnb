
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String? recipeId;
  final String productType;
  final bool isAvailable;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    this.recipeId,
    required this.productType,
    required this.isAvailable,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return MenuModel(
      id: documentId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] ?? '',
      recipeId: map['recipeId'],
      productType: map['productType'] ?? '',
      isAvailable: map['isAvailable'] == true,
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'recipeId': recipeId,
      'productType': productType,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isMadeToOrder => productType == 'made_to_order';

  bool get isFinishedGoods => productType == 'finished_goods';
}
