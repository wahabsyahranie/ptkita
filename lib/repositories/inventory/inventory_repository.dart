import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';

class InventoryPageResult {
  final List<Item> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  InventoryPageResult({
    required this.items,
    required this.lastDocument,
    required this.hasMore,
  });
}

abstract class InventoryRepository {
  Future<InventoryPageResult> fetchItems({
    required InventoryFilter filter,
    required String searchQuery,
    DocumentSnapshot? lastDocument,
    required int limit,
  });

  Future<Item?> getItemById(String id);

  Future<void> addItem(Item item, {File? imageFile});
  Future<void> updateItem(Item item, {File? imageFile});
  Future<void> deleteItem(String id, {String? imageUrl});
}
