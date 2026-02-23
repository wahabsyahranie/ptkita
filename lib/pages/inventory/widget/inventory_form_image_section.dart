import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class InventoryFormImageSection extends StatelessWidget {
  final File? imageFile;
  final String? existingImageUrl;
  final VoidCallback onTap;

  const InventoryFormImageSection({
    super.key,
    required this.imageFile,
    required this.existingImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final previewWidget = imageFile != null
        ? Image.file(imageFile!, fit: BoxFit.cover)
        : (existingImageUrl != null && existingImageUrl!.isNotEmpty
              ? Image.network(existingImageUrl!, fit: BoxFit.cover)
              : const Center(child: Icon(Icons.image, size: 40)));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: MyColors.greySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MyColors.greySoft),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: previewWidget),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: MyColors.black,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.edit, size: 18, color: MyColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
