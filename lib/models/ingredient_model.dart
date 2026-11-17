
import 'package:cloud_firestore/cloud_firestore.dart';

class IngredientModel {
  final String id;
  final String name;
  final String category;
  final String unit;
  final String itemType;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  IngredientModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.itemType,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Mengubah data Firestore menjadi IngredientModel.
  factory IngredientModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return IngredientModel(
      id: documentId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      unit: map['unit'] ?? '',
      itemType: map['itemType'] ?? '',
      isActive: map['isActive'] == true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Mengubah IngredientModel menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'unit': unit,
      'itemType': itemType,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Memeriksa jenis bahan atau barang.
  bool get isRawMaterial => itemType == 'raw_material';

  bool get isFinishedGood => itemType == 'finished_good';
}
