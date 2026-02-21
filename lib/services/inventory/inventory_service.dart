import 'dart:io';

import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'package:flutter_kita/repositories/inventory/inventory_repository.dart';
import 'package:intl/intl.dart';

class InventoryService {
  final InventoryRepository _repository;

  InventoryService(this._repository);

  Future<void> saveItem(Item item, {File? imageFile}) async {
    if (item.id == null) {
      await _repository.addItem(item, imageFile: imageFile);
    } else {
      await _repository.updateItem(item, imageFile: imageFile);
    }
  }

  Future<void> deleteItem(Item item) async {
    if (item.id == null) return;
    await _repository.deleteItem(item.id!, imageUrl: item.imageUrl);
  }

  String formatCurrency(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return "Rp ${formatter.format(value)}";
  }

  Stream<List<Item>> streamItems({
    required InventoryFilter filter,
    required String searchQuery,
  }) {
    final normalizedQuery = searchQuery.toLowerCase().trim();

    return _repository.streamItems(
      filter: filter,
      searchQuery: normalizedQuery,
    );
  }

  Stream<Item?> streamItemById(String id) {
    return _repository.streamItemById(id);
  }
}
