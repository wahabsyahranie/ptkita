// lib/pages/inventory/menu_inventory_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/inventory/add_edit_inventory_page.dart';
import 'package:flutter_kita/pages/inventory/add_inventory_page.dart';
import 'package:flutter_kita/pages/inventory/details_inventory_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/item_model.dart';

class MenuInventoryPage extends StatefulWidget {
  const MenuInventoryPage({super.key});

  @override
  State<MenuInventoryPage> createState() => _MenuInventoryPageState();
}

class _MenuInventoryPageState extends State<MenuInventoryPage> {
  final ScrollController _scrollController = ScrollController();
  int itemsToShow = 6; // jumlah awal yang ditampilkan
  final int _increment = 6; // bertambah berapa tiap load more

  // ====== ADDED: search controller & query ======
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce; // debounce timer
  // =============================================

  @override
  void initState() {
    super.initState();

    // listener untuk infinite scroll (UI-side pagination)
    _scrollController.addListener(() {
      // jika sudah hampir di ujung bawah, tambah itemsToShow
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 120) {
        setState(() {
          itemsToShow += _increment;
        });
      }
    });
  }

  @override
  void dispose() {
    // remove listener by disposing controller
    _scrollController.dispose();

    // dispose search controller and cancel debounce timer
    _searchCtrl.dispose();
    _searchDebounce?.cancel();

    super.dispose();
  }

  // ====== NEW: debounced onChanged handler ======
  void _onSearchChanged(String value) {
    // kalau kosong, apply langsung supaya daftar kembali full (UX-friendly)
    if (value.trim().isEmpty) {
      _searchDebounce?.cancel();
      setState(() {
        _searchQuery = '';
        itemsToShow = 6;
      });
      return;
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.toLowerCase().trim();
        itemsToShow = 6; // reset pagination saat query baru
      });
    });
  }
  // =============================================

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance
        .collection('items')
        .withConverter<Item>(
          fromFirestore: Item.fromFirestore,
          toFirestore: (Item item, _) => item.toFirestore(),
        )
        .orderBy('name');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Data Barang'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          // tombol add
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditInventoryPage(),
                ),
              );
            },
            icon: Container(
              decoration: BoxDecoration(
                color: MyColors.secondary,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          // tombol filter
          IconButton(
            onPressed: () {
              // panggil sheet filter
            },
            icon: Container(
              decoration: BoxDecoration(
                color: MyColors.secondary,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.menu, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            children: [
              // ====== pass the debounced handler to SearchBarWidget ======
              SearchBarWidget(
                controller: _searchCtrl,
                hintText: 'Cari nama atau SKU',
                onChanged: _onSearchChanged, // <-- gunakan fungsi debounce
              ),
              const SizedBox(height: 10),

              // StreamBuilder untuk realtime updates
              Expanded(
                child: StreamBuilder<QuerySnapshot<Item>>(
                  stream: col.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: MyColors.secondary,
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text('Belum ada data.'));
                    }

                    final allItems = docs.map((d) => d.data()).toList();

                    // ====== ADDED: filter client-side using _searchQuery ======
                    final filtered = _searchQuery.isEmpty
                        ? allItems
                        : allItems.where((item) {
                            final name = (item.name ?? '').toLowerCase();
                            final sku = (item.sku ?? '').toLowerCase();
                            return name.contains(_searchQuery) ||
                                sku.contains(_searchQuery);
                          }).toList();
                    // =================================================================

                    // Batasi sesuai itemsToShow (apply pagination to filtered list)
                    final effectiveCount = itemsToShow > filtered.length
                        ? filtered.length
                        : itemsToShow;
                    final showing = filtered.take(effectiveCount).toList();

                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: showing.length,
                      itemBuilder: (context, index) {
                        return _BarangBox(item: showing[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarangBox extends StatelessWidget {
  final Item item;

  const _BarangBox({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final title = item.name ?? '-';
    final sku = item.sku ?? '-';
    final stock = item.stock ?? 0;
    final price = item.price ?? 0;
    final imageUrl = item.imageUrl;
    final description = item.description;

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
                      maxLines: 2,
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
                      'Rp $price',
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
                      'SKU: $sku',
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
