import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'package:flutter_kita/pages/inventory/widget/inventory_appbar.dart';
import 'package:flutter_kita/pages/inventory/widget/inventory_grid.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'widget/filter_sheet.dart';

class InventoryPage extends StatefulWidget {
  final String? initialAvailability;
  final bool fromPush;

  const InventoryPage({
    super.key,
    this.initialAvailability,
    this.fromPush = false,
  });

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  late final InventoryService _service;

  String _searchQuery = '';
  Timer? _searchDebounce;

  late InventoryFilter _appliedFilter;

  List<Item> _items = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;

  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();

    _service = InventoryService(FirestoreInventoryRepository());

    _appliedFilter = InventoryFilter(
      availability: widget.initialAvailability,
      category: null,
      brands: const {},
    );

    _fetchItems();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchItems();
      }
    });
  }

  Future<void> _fetchItems({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    if (isRefresh) {
      _items.clear();
      _lastDocument = null;
      _hasMore = true;
    }

    final result = await _service.getItems(
      filter: _appliedFilter,
      searchQuery: _searchQuery,
      limit: _pageSize,
      lastDocument: _lastDocument,
    );

    if (!mounted) return;

    setState(() {
      _items.addAll(result.items);
      _lastDocument = result.lastDocument;
      _hasMore = result.hasMore;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _searchQuery = value.toLowerCase().trim();
      });

      _fetchItems(isRefresh: true);
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<InventoryFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: FilterSheet(initialFilter: _appliedFilter),
      ),
    );

    if (result != null) {
      setState(() {
        _appliedFilter = result;
      });

      _fetchItems(isRefresh: true);
    }
  }

  Future<void> _handleAdd() async {
    await Navigator.pushNamed(context, '/addInventory');

    _searchCtrl.clear();
    _searchQuery = '';
    _appliedFilter = const InventoryFilter(
      availability: null,
      category: null,
      brands: {},
    );

    _fetchItems(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: InventoryAppBar(
        searchController: _searchCtrl,
        onSearchChanged: _onSearchChanged,
        onAddPressed: _handleAdd,
        onFilterPressed: _openFilterSheet,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: InventoryGrid(
          items: _items,
          isLoading: _isLoading,
          controller: _scrollController,
        ),
      ),
    );
  }
}
