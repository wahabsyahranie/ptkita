import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceItemImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final bool isLoading;

  const MaintenanceItemImage({
    super.key,
    required this.imageProvider,
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

    return Container(
      height: 160,
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.greySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Image(image: imageProvider, fit: BoxFit.contain),
    );
  }
}
