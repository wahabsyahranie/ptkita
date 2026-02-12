import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/inventory_filter_model.dart';
import 'package:flutter_kita/pages/inventory/add_edit_inventory_page.dart';
import 'package:flutter_kita/pages/inventory/details_inventory_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/pages/inventory/widget/filter_sheet.dart';
import 'package:intl/intl.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ScrollController _scrollController = ScrollController();

  // search
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;

  // applied filters (default)
  late InventoryFilter _appliedFilter;

  @override
  void initState() {
    super.initState();

    _appliedFilter = const InventoryFilter(
      availability: null, // semua
      category: null,
      brands: {},
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

  //Pagination
  List<Item> _items = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;

  final int _pageSize = 10;

  Future<void> _fetchItems({bool isRefresh = false}) async {
    if (_isLoading) return;

    if (isRefresh) {
      _hasMore = true; // reset saat refresh
    }

    setState(() => _isLoading = true);

    Query<Item> query = _buildQuery().limit(_pageSize);

    if (!isRefresh && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;

      final newItems = snapshot.docs.map((d) => d.data()).toList();

      if (!mounted) return; // ← TARUH DI SINI

      setState(() {
        if (isRefresh) {
          _items = newItems;
        } else {
          _items.addAll(newItems);
        }
      });
    }

    // ini penting supaya pagination berhenti
    if (snapshot.docs.length < _pageSize) {
      _hasMore = false;
    }

    if (!mounted) return;

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // debounce search
  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      _searchDebounce?.cancel();
      setState(() {
        _searchQuery = '';
        _lastDocument = null;
        _items.clear();
        _hasMore = true;
      });

      _fetchItems(isRefresh: true);
      return;
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      setState(() {
        _searchQuery = value.toLowerCase().trim();
        _lastDocument = null;
        _items.clear();
        _hasMore = true;
      });

      _fetchItems(isRefresh: true); // ← pindahkan ke luar
    });
  }

  /// Build Firestore query dynamically based on _appliedFilter.
  /// Always returns a Query<Item> with converter.
  Query<Item> _buildQuery() {
    Query base = FirebaseFirestore.instance.collection('items');

    // =========================
    // AVAILABILITY (tri-state)
    // =========================
    if (_appliedFilter.availability == 'tersedia') {
      base = base.where('stock', isGreaterThan: 0);
    } else if (_appliedFilter.availability == 'habis') {
      base = base.where('stock', isEqualTo: 0);
    }
    // null = semua → tidak difilter

    // =========================
    // CATEGORY
    // =========================
    if (_appliedFilter.category != null) {
      base = base.where('type', isEqualTo: _appliedFilter.category);
    }

    // =========================
    // BRANDS (≤ 10 aman)
    // =========================
    if (_appliedFilter.brands.isNotEmpty) {
      if (_appliedFilter.brands.length == 1) {
        base = base.where('merk', isEqualTo: _appliedFilter.brands.first);
      } else {
        base = base.where('merk', whereIn: _appliedFilter.brands.toList());
      }
    }

    // =========================
    // SEARCH (prefix search)
    // =========================
    if (_searchQuery.isNotEmpty) {
      base = base.orderBy('name_lowercase').startAt([_searchQuery]).endAt([
        _searchQuery + '\uf8ff',
      ]);
    } else {
      base = base.orderBy('name_lowercase');
    }

    return base.withConverter<Item>(
      fromFirestore: Item.fromFirestore,
      toFirestore: (Item item, _) => item.toFirestore(),
    );
  }

  // open filter sheet and apply result
  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<InventoryFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        // wrap to give rounded white background
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: FilterSheet(initialFilter: _appliedFilter),
        );
      },
    );

    if (result != null) {
      setState(() {
        _appliedFilter = result;
        _lastDocument = null;
        _items.clear();
        _hasMore = true;
      });

      _fetchItems(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // kalau keyboard terbuka → tutup dulu
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
          return false; // jangan pop halaman
        }
        return true; // kalau tidak ada keyboard → boleh pop
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.25),
          title: const Text("Data Barang"),

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      // ← Search bar harus Expanded!
                      Expanded(
                        child: SearchBarWidget(
                          controller: _searchCtrl,
                          hintText: 'Cari dengan nama',
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // tombol add
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: MyColors.secondary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddEditInventoryPage(),
                              ),
                            );
                            if (!mounted) return;
                            setState(() {
                              _appliedFilter = const InventoryFilter(
                                availability: null,
                                category: null,
                                brands: {},
                              );
                              _searchQuery = '';
                              _searchCtrl.clear();
                              _lastDocument = null;
                              _items.clear();
                              _hasMore = true;
                            });
                            _fetchItems(isRefresh: true);
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // tombol filter
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: MyColors.secondary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          onPressed: _openFilterSheet,
                          icon: const Icon(
                            Icons.filter_alt,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              children: [
                // Use stream from dynamic query
                Expanded(
                  child: _items.isEmpty && _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: MyColors.secondary,
                          ),
                        )
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: _items.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _items.length) {
                              final itm = _items[index];
                              return _BarangBox(item: itm);
                            } else {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                    color: MyColors.secondary,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// _BarangBox unchanged from your code
class _BarangBox extends StatelessWidget {
  final Item item;

  const _BarangBox({required this.item});

  //RUPIAH FORMATER
  static final NumberFormat _rupiahFormatter = NumberFormat('#,###', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final title = item.name ?? '-';
    final locationCode = item.locationCode ?? '-';
    final stock = item.stock ?? 0;
    final price = item.price ?? 0;
    final imageUrl = item.imageUrl;
    // final description = item.description;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsInventoryPage(item: item)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: MyColors.secondary,
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 40),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: Icon(Icons.image, size: 40),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Rp ${_rupiahFormatter.format(price)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Stok: $stock',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rak: $locationCode',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
