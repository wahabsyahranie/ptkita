import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/inventory/widget/inventory_card.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';

class InventoryGridSection extends StatelessWidget {
  final List items;
  final InventoryService service;

  const InventoryGridSection({
    super.key,
    required this.items,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];

          return InventoryCard(
            item: item,
            service: service,
          );
        },
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
    );
  }
}