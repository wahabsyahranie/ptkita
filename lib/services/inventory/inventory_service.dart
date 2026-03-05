import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/item_brand.dart';
import 'package:flutter_kita/core/utils/brand_logo_mapper.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'package:flutter_kita/repositories/inventory/inventory_repository.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:intl/intl.dart';

//INJECT USER SERVICE
import 'package:flutter_kita/services/user/user_service.dart';
import 'package:flutter_kita/models/user/user_model.dart';

class InventoryService extends ChangeNotifier {
  final InventoryRepository _repository;
  final UserService _userService;

  InventoryService(this._repository, this._userService);

  // =========================================================
  // ====================== PAGINATION STATE =================
  // =========================================================

  final int _pageSize = 5;

  final List<Item> _items = [];
  PaginationCursor? _cursor;

  bool _hasMore = true;
  bool _isLoading = false;

  InventoryFilter? _currentFilter;
  String _currentSearch = '';

  List<Item> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> resetAndFetch({
    required InventoryFilter filter,
    required String searchQuery,
  }) async {
    _items.clear();
    _cursor = null;
    _hasMore = true;
    _currentFilter = filter;
    _currentSearch = searchQuery.toLowerCase().trim();

    await fetchNextPage();
    notifyListeners();
  }

  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    if (_currentFilter == null) return;

    _isLoading = true;

    try {
      final result = await _repository.fetchItemsPage(
        filter: _currentFilter!,
        searchQuery: _currentSearch,
        limit: _pageSize,
        cursor: _cursor,
      );

      for (final newItem in result.items) {
        final alreadyExists = _items.any(
          (existing) => existing.id == newItem.id,
        );

        if (!alreadyExists) {
          _items.add(newItem);
        }
      }
      _cursor = result.cursor;
      _hasMore = result.hasMore;

      notifyListeners();
    } catch (e) {
      rethrow; // biarkan UI tahu kalau mau handle
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_currentFilter == null) return;

    await resetAndFetch(filter: _currentFilter!, searchQuery: _currentSearch);
  }

  // =========================================================
  // ====================== SAVE =============================
  // =========================================================

  Future<void> saveItem(Item item, {File? imageFile}) async {
    final normalized = item.copyWith(
      type: (item.type == null || item.type!.isEmpty) ? 'unit' : item.type,
      merk: (item.merk == null || item.merk!.isEmpty) ? 'nomerk' : item.merk,
    );

    final UserModel? currentUser = await _userService.currentUserProfile.first;

    if (currentUser == null) {
      throw Exception("User tidak ditemukan");
    }

    final now = DateTime.now();

    // ==============================
    // CREATE
    // ==============================
    if (normalized.id == null || normalized.id!.isEmpty) {
      final base = normalized.movementBaseScore;

      final newItem = normalized.copyWith(
        movementAutoScore: 0,
        movementTotalScore: base,

        createdById: currentUser.id,
        createdByName: currentUser.name,
        createdAt: now,
        lastEditedById: currentUser.id,
        lastEditedByName: currentUser.name,
        lastEditedAt: now,
      );

      await _repository.addItem(newItem, imageFile: imageFile);
      return;
    }

    // ==============================
    // UPDATE
    // ==============================

    final existing = await _repository.streamItemById(normalized.id!).first;

    if (existing == null) {
      throw Exception("Item tidak ditemukan saat update");
    }

    final newTotal = normalized.movementBaseScore + existing.movementAutoScore;

    final updatedItem = normalized.copyWith(
      movementAutoScore: existing.movementAutoScore,
      movementTotalScore: newTotal,

      // ===== PRESERVE CREATED =====
      createdById: existing.createdById,
      createdByName: existing.createdByName,
      createdAt: existing.createdAt,

      // ===== UPDATE LAST EDITED =====
      lastEditedById: currentUser.id,
      lastEditedByName: currentUser.name,
      lastEditedAt: now,
    );

    await _repository.updateItem(updatedItem, imageFile: imageFile);
  }

  // =========================================================
  // ====================== DELETE ===========================
  // =========================================================

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
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

  ////Movement Speed Label
  String getMovementLabel(Item item) {
    final base = item.movementBaseScore;

    if (base >= 1000) return "Fast";
    if (base >= 500) return "Normal";
    return "Jarang";
  }

  Color getMovementColor(Item item) {
    final base = item.movementBaseScore;

    if (base >= 1000) return MyColors.success;
    if (base >= 500) return MyColors.warning;
    return MyColors.background;
  }
}
