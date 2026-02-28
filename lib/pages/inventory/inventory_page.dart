import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'package:flutter_kita/pages/inventory/add_edit_inventory_page.dart';
import 'package:flutter_kita/pages/inventory/widget/inventory_appbar.dart';
import 'package:flutter_kita/pages/inventory/widget/inventory_grid.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';
import 'package:flutter_kita/repositories/user/firestore_user_repository.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/services/user/user_service.dart';
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

  @override
  void initState() {
    super.initState();

    // final repo = FirestoreInventoryRepository();
    // repo.migrateMovementFields(); // panggil sekali

    _service = InventoryService(
      FirestoreInventoryRepository(),
      UserService(FirestoreUserRepository()),
    );

    _appliedFilter = InventoryFilter(
      availability: widget.initialAvailability,
      category: null,
      brands: const {},
    );

    // Fetch pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service
          .resetAndFetch(filter: _appliedFilter, searchQuery: _searchQuery)
          .then((_) {
            if (mounted) setState(() {});
          });
    });

    // Scroll listener
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_service.isLoading || !_service.hasMore) return;

        await _service.fetchNextPage();

        if (mounted) setState(() {});
      }
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;

      _searchQuery = value;

      await _service.resetAndFetch(
        filter: _appliedFilter,
        searchQuery: _searchQuery,
      );

      if (mounted) setState(() {});
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
      _appliedFilter = result;

      await _service.resetAndFetch(
        filter: _appliedFilter,
        searchQuery: _searchQuery,
      );

      if (mounted) setState(() {});
    }
  }

  Future<void> _handleAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditInventoryPage()),
    );

    _searchCtrl.clear();
    _searchQuery = '';
    _appliedFilter = const InventoryFilter(
      availability: null,
      category: null,
      brands: {},
    );

    await _service.resetAndFetch(
      filter: _appliedFilter,
      searchQuery: _searchQuery,
    );

    if (mounted) setState(() {});
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
        child: RefreshIndicator(
          onRefresh: () async {
            await _service.refresh();
            if (mounted) setState(() {});
          },
          child: _service.items.isEmpty && _service.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: MyColors.secondary),
                )
              : _service.items.isEmpty
              ? const Center(child: Text("Data tidak ditemukan"))
              : ListView(
                  controller: _scrollController,
                  children: [
                    InventoryGrid(items: _service.items, service: _service),

                    if (_service.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: MyColors.secondary,
                          ),
                        ),
                      ),

                    if (!_service.hasMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text("Semua data telah dimuat")),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
