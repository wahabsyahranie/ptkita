import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/pages/inventory/details_inventory_page.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InventoryCard extends StatelessWidget {
  final Item item;
  final InventoryService service;

  const InventoryCard({super.key, required this.item, required this.service});

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
          MaterialPageRoute(
            builder: (_) =>
                DetailsInventoryPage(itemId: item.id!, service: service),
          ),
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
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      )
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
              Text(service.formatCurrency(price)),
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
