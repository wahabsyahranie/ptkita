// import 'dart:io';

// import 'package:flutter_kita/models/inventory/item_model.dart';
// import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
// import 'package:flutter_kita/repositories/inventory/inventory_repository.dart';
// import 'package:intl/intl.dart';

// class InventoryService {
//   final InventoryRepository _repository;

//   InventoryService(this._repository);

//   Future<void> saveItem(Item item, {File? imageFile}) async {
//     if (item.id == null) {
//       await _repository.addItem(item, imageFile: imageFile);
//     } else {
//       await _repository.updateItem(item, imageFile: imageFile);
//     }
//   }

//   Future<void> deleteItemById({required String id, String? imageUrl}) {
//     return _repository.deleteItem(id, imageUrl: imageUrl);
//   }

//   String formatCurrency(int value) {
//     final formatter = NumberFormat('#,###', 'id_ID');
//     return "Rp ${formatter.format(value)}";
//   }

//   Stream<List<Item>> streamItems({
//     required InventoryFilter filter,
//     required String searchQuery,
//   }) {
//     final normalizedQuery = searchQuery.toLowerCase().trim();

//     return _repository.streamItems(
//       filter: filter,
//       searchQuery: normalizedQuery,
//     );
//   }

//   Stream<Item?> streamItemById(String id) {
//     return _repository.streamItemById(id);
//   }
// }
import 'dart:io';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'package:flutter_kita/repositories/inventory/inventory_repository.dart';
import 'package:intl/intl.dart';

class InventoryService {
  final InventoryRepository _repository;

  InventoryService(this._repository);

  // =========================================================
  // ====================== SAVE =============================
  // =========================================================

  Future<void> saveItem(Item item, {File? imageFile}) async {
    final normalized = item.copyWith(
      type: (item.type == null || item.type!.isEmpty) ? 'unit' : item.type,
      merk: (item.merk == null || item.merk!.isEmpty) ? 'nomerk' : item.merk,
    );

    if (normalized.id == null || normalized.id!.isEmpty) {
      await _repository.addItem(normalized, imageFile: imageFile);
    } else {
      await _repository.updateItem(normalized, imageFile: imageFile);
    }
  }

  // =========================================================
  // ====================== DELETE ===========================
  // =========================================================

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
  }

  // =========================================================
  // ====================== STREAM LIST ======================
  // =========================================================

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

  // =========================================================
  // ====================== STREAM DETAIL ====================
  // =========================================================

  Stream<Item?> streamItemById(String id) {
    return _repository.streamItemById(id);
  }

  // =========================================================
  // ====================== FORMAT ===========================
  // =========================================================

  String formatCurrency(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return "Rp ${formatter.format(value)}";
  }
}
