import 'package:flutter/material.dart';
import '../../../styles/colors.dart';
import '../../../models/transaction/cart_item_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onDelete;

  const CartItemCard({super.key, required this.item, required this.onDelete});

  String _fmt(int v) {
    final s = v.toString().split('').reversed.toList();
    final parts = <String>[];

    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.skip(i).take(3).toList().reversed.join());
    }

    return parts.reversed.join('.');
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = item.price * item.qty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 18),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Qty ${item.qty} × Rp ${_fmt(item.price)}',
            style: const TextStyle(fontSize: 12),
          ),

          Text(
            item.hasWarranty
                ? 'Garansi ${item.warrantyYear} Tahun (${item.warrantyType})'
                : 'Tanpa Garansi',
            style: const TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 6),

          Text(
            'Subtotal: Rp ${_fmt(subtotal)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
