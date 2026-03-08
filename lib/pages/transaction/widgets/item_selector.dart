import 'package:flutter/material.dart';
import '../../../styles/colors.dart';

class ItemSelector extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String? selectedItemId;
  final ValueChanged<String?> onChanged;

  const ItemSelector({
    super.key,
    required this.items,
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
  final ValueChanged<String> onSelected;

  const _ItemSearchSheet({required this.items, required this.onSelected});

  @override
  State<_ItemSearchSheet> createState() => _ItemSearchSheetState();
}

class _ItemSearchSheetState extends State<_ItemSearchSheet> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      final name = item['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

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
                  hintText: 'Cari barang...',
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
                        title: Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          "Stok: ${item['stock']}",
                          style: const TextStyle(fontSize: 12),
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
