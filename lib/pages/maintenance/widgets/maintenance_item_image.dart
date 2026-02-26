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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        width: 140,
        color: Colors.white, // background agar logo kontras
        alignment: Alignment.center,
        child: Image(image: imageProvider, fit: BoxFit.contain),
      ),
    );
  }
}
