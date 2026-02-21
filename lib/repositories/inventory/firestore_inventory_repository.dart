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
  Future<InventoryPageResult> fetchItems({
    required InventoryFilter filter,
    required String searchQuery,
    DocumentSnapshot? lastDocument,
    required int limit,
  }) async {
    Query<Item> query = _collection;

    final bool isRangeStock = filter.availability == 'tersedia';

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

    // Ordering
    if (isRangeStock) {
      query = query.orderBy('stock');
    }

    query = query.orderBy('name_lowercase');

    // Search prefix
    if (searchQuery.isNotEmpty) {
      query = query.startAt([searchQuery]).endAt(['$searchQuery\uf8ff']);
    }

    query = query.limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final items = snapshot.docs.map((e) => e.data()).toList();

    return InventoryPageResult(
      items: items,
      lastDocument: snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : lastDocument,
      hasMore: snapshot.docs.length == limit,
    );
  }

  @override
  Future<void> addItem(Item item) async {
    await _collection.add(item);
  }

  @override
  Future<void> updateItem(Item item) async {
    if (item.id == null) {
      throw Exception('Item id is null');
    }

    await _collection.doc(item.id).set(item, SetOptions(merge: true));
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

  @override
  Future<Item?> getItemById(String id) async {
    final snap = await _collection.doc(id).get();
    if (!snap.exists) return null;
    return snap.data();
  }
}
