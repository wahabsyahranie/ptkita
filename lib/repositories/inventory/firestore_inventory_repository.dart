import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'inventory_repository.dart';

class FirestoreInventoryRepository implements InventoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirestoreInventoryRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Item> get _collection => _firestore
      .collection('items')
      .withConverter<Item>(
        fromFirestore: Item.fromFirestore,
        toFirestore: (item, _) => item.toFirestore(),
      );

  @override
  Stream<List<Item>> streamItems({
    required InventoryFilter filter,
    required String searchQuery,
  }) {
    Query<Item> query = _collection;

    // Availability
    if (filter.availability == 'tersedia') {
      query = query.where('stock', isGreaterThan: 0);
    } else if (filter.availability == 'habis') {
      query = query.where('stock', isEqualTo: 0);
    }

    // Category
    if (filter.category != null) {
      query = query.where('type', isEqualTo: filter.category);
    }

    // Brand
    if (filter.brands.isNotEmpty) {
      if (filter.brands.length == 1) {
        query = query.where('merk', isEqualTo: filter.brands.first);
      } else {
        query = query.where('merk', whereIn: filter.brands.toList());
      }
    }

    query = query.orderBy('name_lowercase');

    if (searchQuery.isNotEmpty) {
      query = query.startAt([searchQuery]).endAt(['$searchQuery\uf8ff']);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((e) => e.data()).toList(),
    );
  }

  @override
  Stream<Item?> streamItemById(String id) {
    return _collection
        .doc(id)
        .snapshots()
        .map((snap) => snap.exists ? snap.data() : null);
  }

  @override
  Future<void> addItem(Item item, {File? imageFile}) async {
    String? imageUrl = item.imageUrl;

    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile);
    }

    final newItem = item.copyWith(
      imageUrl: imageUrl,
      nameLowercase: item.name?.toLowerCase(),
    );

    await _collection.add(newItem);
  }

  @override
  Future<void> updateItem(Item item, {File? imageFile}) async {
    if (item.id == null) {
      throw Exception('Item id is null');
    }

    String? imageUrl = item.imageUrl;

    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile);
    }

    final updatedItem = item.copyWith(
      imageUrl: imageUrl,
      nameLowercase: item.name?.toLowerCase(),
    );

    await _collection.doc(item.id).set(updatedItem, SetOptions(merge: true));
  }

  @override
  Future<void> deleteItem(String id, {String? imageUrl}) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      } catch (_) {}
    }

    await _collection.doc(id).delete();
  }

  Future<String?> _uploadImage(File file) async {
    final fileName =
        'items/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

    final ref = _storage.ref().child(fileName);
    final snapshot = await ref.putFile(file);
    return await snapshot.ref.getDownloadURL();
  }
}
