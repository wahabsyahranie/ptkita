import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceItemImage extends StatelessWidget {
  final String? imageUrl;
  final bool isLoading;

  const MaintenanceItemImage({
    super.key,
    required this.imageUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: MyColors.secondary),
        ),
      );
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        size: 100,
        color: MyColors.greySoft,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl!,
        height: 140,
        width: 140,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.broken_image,
            size: 100,
            color: MyColors.greySoft,
          );
        },
      ),
    );
  }
}
