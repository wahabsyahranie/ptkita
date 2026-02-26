import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/item_brand.dart';
import 'package:flutter_kita/core/utils/brand_logo_mapper.dart';
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
  // ====================== FORMAT UANG===========================
  // =========================================================

  String formatCurrency(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return "Rp ${formatter.format(value)}";
  }

  ImageProvider resolveImage(Item item) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(item.imageUrl!);
    }

    final merk = ItemmerkX.fromString(item.merk);
    final assetPath = merkLogoMapper.getAssetPath(merk);

    return AssetImage(assetPath);
  }
}
