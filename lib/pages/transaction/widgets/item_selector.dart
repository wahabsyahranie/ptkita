import 'package:flutter/material.dart';
import '../../../styles/colors.dart';

import 'package:flutter_kita/core/search/search_engine.dart';

class ItemSelector extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String? selectedItemId;
  final ValueChanged<String?> onChanged;
  final InvertedIndex searchEngine;

  const ItemSelector({
    super.key,
    required this.items,
    required this.searchEngine,
    required this.selectedItemId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedItem = items.where((e) => e['id'] == selectedItemId).toList();

    return InkWell(
      onTap: () {
        _openItemSearch(context);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Pilih Item / Barang',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          selectedItem.isEmpty ? 'Pilih item' : selectedItem.first['name'],
        ),
      ),
    );
  }

  void _openItemSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final height = MediaQuery.of(context).size.height * 0.6;

        return SizedBox(
          height: height,
          child: _ItemSearchSheet(
            items: items,
            searchEngine: searchEngine,
            onSelected: (id) {
              Navigator.pop(context);
              onChanged(id);
            },
          ),
        );
      },
    );
  }
}

class _ItemSearchSheet extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final InvertedIndex searchEngine;
  final ValueChanged<String> onSelected;

  const _ItemSearchSheet({
    required this.items,
    required this.searchEngine,
    required this.onSelected,
  });

  @override
  State<_ItemSearchSheet> createState() => _ItemSearchSheetState();
}

class _ItemSearchSheetState extends State<_ItemSearchSheet> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    // final q = query.toLowerCase();

    List<Map<String, dynamic>> filtered;

    if (query.isEmpty) {
      filtered = widget.items;
    } else {
      final ids = widget.searchEngine.search(query);

      filtered = widget.items
          .where((item) => ids.contains(item['id'].toString()))
          .toList();

      /// SORT BY STOCK
      filtered.sort((a, b) {
        final nameA = a['name'].toString().toLowerCase();
        final nameB = b['name'].toString().toLowerCase();

        // final brandA = (a['brandName'] ?? '').toString().toLowerCase();
        // final brandB = (b['brandName'] ?? '').toString().toLowerCase();

        final stockA = a['stock'] ?? 0;
        final stockB = b['stock'] ?? 0;

        /// PRIORITY 1: name match
        final nameMatchA = nameA.contains(query);
        final nameMatchB = nameB.contains(query);

        if (nameMatchA && !nameMatchB) return -1;
        if (!nameMatchA && nameMatchB) return 1;

        /// PRIORITY 2: stock available
        final availableA = stockA > 0;
        final availableB = stockB > 0;

        if (availableA && !availableB) return -1;
        if (!availableA && availableB) return 1;

        /// PRIORITY 3: alphabetical
        return nameA.compareTo(nameB);
      });
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            /// DRAG HANDLE
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            /// SEARCH FIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari barang/Brand/Type Unit',
                  hintStyle: const TextStyle(color: MyColors.secondary),

                  prefixIcon: const Icon(
                    Icons.search,
                    color: MyColors.secondary,
                  ),

                  filled: true,
                  fillColor: MyColors.white,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: MyColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (v) {
                  setState(() {
                    query = v;
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            /// ITEM LIST
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final item = filtered[i];

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),

                            /// BRAND + TYPE
                            Text(
                              "${item['brandName'] ?? '-'} • ${item['typeUnit'] ?? '-'}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 2),

                            /// STOCK
                            Text(
                              "Stok: ${item['stock']}",
                              style: TextStyle(
                                fontSize: 12,
                                color: item['stock'] <= 0
                                    ? Colors.red
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          widget.onSelected(item['id']);
                        },
                      ),

                      const Divider(height: 1),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
