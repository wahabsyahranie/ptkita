import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'package:flutter_kita/repositories/inventory/inventory_repository.dart';

class InventoryService {
  final InventoryRepository _repository;

  InventoryService(this._repository);

  Future<InventoryPageResult> getItems({
    required InventoryFilter filter,
    required String searchQuery,
    required int limit,
    dynamic lastDocument,
  }) {
    return _repository.fetchItems(
      filter: filter,
      searchQuery: searchQuery,
      lastDocument: lastDocument,
      limit: limit,
    );
  }

  Future<void> saveItem(Item item) async {
    if (item.id == null) {
      await _repository.addItem(item);
    } else {
      await _repository.updateItem(item);
    }
  }

  Future<void> deleteItem(Item item) async {
    if (item.id == null) return;
    await _repository.deleteItem(item.id!, imageUrl: item.imageUrl);
  }

  Future<Item?> getItemById(String id) {
    return _repository.getItemById(id);
  }
}
