import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';

abstract class InventoryRepository {
  Future<void> addItem(Item item, {File? imageFile});

  Future<void> updateItem(Item item, {File? imageFile});

  Future<void> deleteItem(String id, {String? imageUrl});

  Stream<List<Item>> streamItems({
    required InventoryFilter filter,
    required String searchQuery,
  });

  Stream<Item?> streamItemById(String id);

  Future<PaginatedResult<Item>> fetchItemsPage({
    required InventoryFilter filter,
    required String searchQuery,
    required int limit,
    DocumentSnapshot? lastDocument,
  });
}
