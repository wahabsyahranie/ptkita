import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'inventory_card.dart';

class InventoryGrid extends StatelessWidget {
  final List<Item> items;
  final bool isLoading;
  final ScrollController controller;

  const InventoryGrid({
    super.key,
    required this.items,
    required this.isLoading,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: MyColors.secondary),
      );
    }

    if (items.isEmpty) {
      return const Center(child: Text("Data tidak ditemukan"));
    }

    return GridView.builder(
      controller: controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return InventoryCard(item: items[index]);
        } else {
          return const Center(
            child: CircularProgressIndicator(color: MyColors.secondary),
          );
        }
      },
    );
  }
}
