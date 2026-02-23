import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'inventory_card.dart';

class InventoryGrid extends StatelessWidget {
  final List<Item> items;
  final InventoryService service;

  const InventoryGrid({super.key, required this.items, required this.service});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text("Data tidak ditemukan"));
    }

    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        return InventoryCard(item: items[index], service: service);
      },
    );
  }
}
