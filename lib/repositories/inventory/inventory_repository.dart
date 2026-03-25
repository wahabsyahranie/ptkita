import 'dart:io';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';

class PaginationCursor {
  final Object? raw;

  const PaginationCursor(this.raw);
}

class PaginatedResult<T> {
  final List<T> items;
  final PaginationCursor? cursor;
  final bool hasMore;

  PaginatedResult({
    required this.items,
    required this.cursor,
    required this.hasMore,
  });
}

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
    PaginationCursor? cursor,
  });

  Future<bool> isPartNumberExists(String partNumber, {String? excludeId});
}
