import 'dart:io';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';

abstract class InventoryRepository {
  Future<void> addItem(Item item, {File? imageFile});

  Future<void> updateItem(Item item, {File? imageFile});

  Future<void> deleteItem(String id, {String? imageUrl});

  Stream<List<Item>> streamItems({
    required InventoryFilter filter,
    required String searchQuery,
  });

  Stream<Item?> streamItemById(String id);
}
