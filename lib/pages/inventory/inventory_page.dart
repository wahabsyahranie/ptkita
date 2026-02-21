import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'package:flutter_kita/pages/inventory/add_edit_inventory_page.dart';
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

  @override
  void initState() {
    super.initState();

    _service = InventoryService(FirestoreInventoryRepository());

    _appliedFilter = InventoryFilter(
      availability: widget.initialAvailability,
      category: null,
      brands: const {},
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      setState(() {
        _searchQuery = value;
      });
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
        child: StreamBuilder<List<Item>>(
          stream: _service.streamItems(
            filter: _appliedFilter,
            searchQuery: _searchQuery,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: MyColors.secondary),
              );
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Terjadi kesalahan memuat data"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Data tidak ditemukan"));
            }

            final items = snapshot.data!;

            return InventoryGrid(items: items, service: _service);
          },
        ),
      ),
    );
  }
}
