// lib/pages/inventory/add_edit_inventory_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/pages/inventory/form_inventory_page.dart';

class AddEditInventoryPage extends StatelessWidget {
  final Item? item; // null = add; non-null = edit

  const AddEditInventoryPage({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    final isEdit = item != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Barang' : 'Tambah Barang'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: FormInventoryPage(
        initialItem: item,
        onSaved: () {
          // close page after saved
          if (Navigator.canPop(context)) Navigator.of(context).pop(true);
        },
      ),
    );
  }
}
