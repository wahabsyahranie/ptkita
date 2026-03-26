import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'inventory_repository.dart';

class FirestoreInventoryRepository implements InventoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _brandCollection = FirebaseFirestore.instance.collection('brands');

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
      query = query.where('category', isEqualTo: filter.category);
    }

    // Brand
    if (filter.brands.isNotEmpty) {
      if (filter.brands.length == 1) {
        query = query.where('brandName', isEqualTo: filter.brands.first);
      } else {
        query = query.where('brandName', whereIn: filter.brands.toList());
      }
    }

    // ==============================
    // ORDERING LOGIC
    // ==============================

    if (searchQuery.isEmpty) {
      if (filter.availability == 'tersedia') {
        // Karena ada range query (stock > 0),
        // Firestore wajib orderBy stock dulu
        query = query
            .orderBy('stock')
            .orderBy('movementTotalScore', descending: true);
      } else {
        query = query.orderBy('movementTotalScore', descending: true);
      }
    } else {
      query = query.orderBy('name_lowercase');
      query = query.startAt([searchQuery]).endAt(['$searchQuery\uf8ff']);
    }

    ////RETURN
    return query.snapshots().asyncMap((snapshot) async {
      final items = snapshot.docs.map((e) => e.data()).toList();

      // ambil semua brand
      final brandSnapshot = await _brandCollection.get();

      final brandMap = {
        for (var doc in brandSnapshot.docs)
          (doc.data()['name'] as String): doc.data(),
      };

      // inject logoUrl ke item (sementara via copyWith)
      return items.map((item) {
        final brandData = brandMap[item.brandName];
        final logoUrl = brandData?['logoUrl'] as String?;

        return item.copyWith(
          brandLogoUrl: logoUrl, // ✅ FIX DI SINI
        );
      }).toList();
    });
  }

  // PAGINATION
  @override
  Future<PaginatedResult<Item>> fetchItemsPage({
    required InventoryFilter filter,
    required String searchQuery,
    required int limit,
    PaginationCursor? cursor,
  }) async {
    Query<Item> query = _collection;

    // ==============================
    // FILTER LOGIC (SAMA DENGAN STREAM)
    // ==============================

    if (filter.availability == 'tersedia') {
      query = query.where('stock', isGreaterThan: 0);
    } else if (filter.availability == 'habis') {
      query = query.where('stock', isEqualTo: 0);
    }

    if (filter.category != null) {
      query = query.where('category', isEqualTo: filter.category);
    }

    if (filter.brands.isNotEmpty) {
      if (filter.brands.length == 1) {
        query = query.where('brandName', isEqualTo: filter.brands.first);
      } else {
        query = query.where('brandName', whereIn: filter.brands.toList());
      }
    }

    // ==============================
    // ORDERING (HARUS IDENTIK)
    // ==============================

    if (searchQuery.isEmpty) {
      if (filter.availability == 'tersedia') {
        query = query
            .orderBy('stock')
            .orderBy('movementTotalScore', descending: true);
      } else {
        query = query.orderBy('movementTotalScore', descending: true);
      }
    } else {
      query = query.orderBy('name_lowercase');
      query = query.startAt([searchQuery]).endAt(['$searchQuery\uf8ff']);
    }

    // ==============================
    // PAGINATION
    // ==============================

    query = query.limit(limit);

    // if (lastDocument != null) {
    //   query = query.startAfterDocument(lastDocument);
    // }
    if (cursor != null && cursor.raw is DocumentSnapshot) {
      query = query.startAfterDocument(cursor.raw as DocumentSnapshot);
    }

    final snapshot = await query.get();

    final items = snapshot.docs.map((e) => e.data()).toList();

    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    final hasMore = snapshot.docs.length == limit;

    // ambil semua brand
    final brandSnapshot = await _brandCollection.get();

    final brandMap = {
      for (var doc in brandSnapshot.docs)
        (doc.data()['name'] as String): doc.data(),
    };

    final enrichedItems = items.map((item) {
      final brandData = brandMap[item.brandName];
      final logoUrl = brandData?['logoUrl'] as String?;

      return item.copyWith(brandLogoUrl: logoUrl);
    }).toList();

    return PaginatedResult<Item>(
      items: enrichedItems,
      cursor: lastDoc != null ? PaginationCursor(lastDoc) : null,
      hasMore: hasMore,
    );
  }

  @override
  Stream<Item?> streamItemById(String id) {
    return _collection.doc(id).snapshots().asyncMap((snap) async {
      final item = snap.exists ? snap.data() : null;
      if (item == null) return null;

      final brandSnapshot = await _brandCollection.get();

      final brandMap = {
        for (var doc in brandSnapshot.docs)
          (doc.data()['name'] as String): doc.data(),
      };

      final brandData = brandMap[item.brandName];
      final logoUrl = brandData?['logoUrl'] as String?;

      return item.copyWith(brandLogoUrl: logoUrl);
    });
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

  // =========================================================
  // ====================== MIGRASI ===========================
  // =========================================================
  Future<void> migrateMovementFields() async {
    final snapshot = await _firestore.collection('items').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (!data.containsKey('movementTotalScore')) {
        await doc.reference.update({
          'movementBaseScore': 500,
          'movementAutoScore': 0,
          'movementTotalScore': 500,
        });
      }
    }
  }

  @override
  Future<bool> isPartNumberExists(
    String partNumber, {
    String? excludeId,
  }) async {
    final query = await _collection
        .where('partNumber', isEqualTo: partNumber)
        .get();

    for (final doc in query.docs) {
      if (excludeId == null || doc.id != excludeId) {
        return true;
      }
    }

    return false;
  }
}
