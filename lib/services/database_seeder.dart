
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/initial_menus.dart';
import '../data/initial_ingredients.dart';
import '../data/initial_recipes.dart';
import '../data/initial_inventory.dart';

class DatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, int>> seedInitialData() async {
    // Pastikan pengguna sudah login.
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    // Pastikan hanya Owner yang dapat menjalankan seeder.
    final userDocument = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final userData = userDocument.data();

    if (!userDocument.exists ||
        userData == null ||
        userData['role'] != 'owner' ||
        userData['isActive'] != true) {
      throw Exception(
        'Hanya Owner aktif yang dapat menjalankan seeder.',
      );
    }

    // Ambil batch untuk penulisan data.
    final batch = _firestore.batch();

    // Masukkan data ke masing-masing koleksi.
    final menuCount = await _addMissingDocuments(
      batch: batch,
      collectionName: 'menus',
      dataList: initialMenus,
    );

    final ingredientCount = await _addMissingDocuments(
      batch: batch,
      collectionName: 'ingredients',
      dataList: initialIngredients,
    );

    final recipeCount = await _addMissingDocuments(
      batch: batch,
      collectionName: 'recipes',
      dataList: initialRecipes,
    );

    final inventoryCount = await _addMissingDocuments(
      batch: batch,
      collectionName: 'inventory',
      dataList: initialInventory,
    );

    // Simpan semua perubahan ke Firestore.
    await batch.commit();

    return {
      'menus': menuCount,
      'ingredients': ingredientCount,
      'recipes': recipeCount,
      'inventory': inventoryCount,
    };
  }

  
  Future<int> _addMissingDocuments({
    required WriteBatch batch,
    required String collectionName,
    required List<Map<String, dynamic>> dataList,
  }) async {
    final collection = _firestore.collection(collectionName);

    // Ambil ID dokumen yang sudah tersedia.
    final existingSnapshot = await collection.get();

    final existingIds = existingSnapshot.docs
        .map((document) => document.id)
        .toSet();

    // Memastikan ID data awal tidak kosong atau duplikat.
    final processedIds = <String>{};

    int addedCount = 0;

    for (final item in dataList) {
      final documentId = item['id'];

      if (documentId is! String || documentId.trim().isEmpty) {
        throw Exception(
          'ID dokumen tidak valid pada koleksi $collectionName.',
        );
      }

      if (!processedIds.add(documentId)) {
        throw Exception(
          'ID $documentId duplikat pada koleksi $collectionName.',
        );
      }

      // Lewati dokumen yang sudah tersedia.
      if (existingIds.contains(documentId)) {
        continue;
      }

      final documentData = Map<String, dynamic>.from(item);

      documentData.remove('id');

      documentData['createdAt'] = FieldValue.serverTimestamp();
      documentData['updatedAt'] = FieldValue.serverTimestamp();

      batch.set(
        collection.doc(documentId),
        documentData,
      );

      addedCount++;
    }

    return addedCount;
  }

}
