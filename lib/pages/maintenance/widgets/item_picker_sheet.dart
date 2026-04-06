import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/services/maintenance/maintenance_service.dart';

class ItemPickerSheet extends StatefulWidget {
  final MaintenanceService service;

  const ItemPickerSheet({super.key, required this.service});

  @override
  State<ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<ItemPickerSheet> {
  final TextEditingController _controller = TextEditingController();

  List<Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems('');
  }

  Future<void> _loadItems(String query) async {
    setState(() => _isLoading = true);

    final result = await widget.service.getItemsForPicker(query);

    setState(() {
      _items = result;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    _loadItems(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Barang",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 🔍 SEARCH
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Cari item...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // 📦 LIST (WAJIB dibatasi tinggi)
            SizedBox(
              height: 300,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];

                        return ListTile(
                          title: Text(item.name ?? '-'),
                          subtitle: _buildSubtitle(item),
                          onTap: () {
                            Navigator.pop(context, item);
                          },
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(Item item) {
    if (item.category == 'unit') {
      return Text('Unit: ${item.typeUnit ?? '-'}');
    }

    return Text(
      'Part: ${item.partNumber ?? '-'} • Unit: ${item.typeUnit ?? '-'}',
    );
  }
}
