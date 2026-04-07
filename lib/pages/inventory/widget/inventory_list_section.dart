import 'package:flutter/material.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/inventory/details_inventory_page.dart';

class InventoryListSection extends StatelessWidget {
  final List items;
  final InventoryService service;

  const InventoryListSection({
    super.key,
    required this.items,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailsInventoryPage(itemId: item.id!),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MyColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 🔹 ICON (pengganti gambar)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: MyColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    color: MyColors.secondary,
                  ),
                ),

                const SizedBox(width: 12),

                // 🔹 TEXT INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.brandName ?? 'No Brand',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),

                      // 💰 HARGA
                      Text(
                        item.price != null
                            ? service.formatCurrency(item.price!)
                            : '-',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔹 STATUS / AVAILABILITY
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (item.stock ?? 0) > 0
                          ? MyColors.success.withValues(alpha: 0.1)
                          : MyColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (item.stock ?? 0) > 0 ? 'Tersedia' : 'Habis',
                      style: TextStyle(
                        color: (item.stock ?? 0) > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }, childCount: items.length),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'unit':
        return Icons.agriculture; // unit
      case 'part':
        return Icons.settings; // part / komponen
      default:
        return Icons.inventory_2;
    }
  }
}
