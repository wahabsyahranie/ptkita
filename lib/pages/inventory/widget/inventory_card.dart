import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/pages/inventory/details_inventory_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:intl/intl.dart';

class InventoryCard extends StatelessWidget {
  final Item item;

  const InventoryCard({super.key, required this.item});

  static final NumberFormat _rupiahFormatter = NumberFormat('#,###', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final title = item.name ?? '-';
    final locationCode = item.locationCode ?? '-';
    final stock = item.stock ?? 0;
    final price = item.price ?? 0;
    final imageUrl = item.imageUrl;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsInventoryPage(item: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: MyColors.black.withValues(alpha: 0.08),
              blurRadius: 6,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 3 / 2,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: MyColors.greySoft,
                        child: const Center(child: Icon(Icons.image)),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text("Rp ${_rupiahFormatter.format(price)}"),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Stok: $stock"),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Rak: $locationCode",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
