import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceDetailHeader extends StatelessWidget {
  final String itemName;
  final String lastMaintenance;
  final Widget imageWidget;

  const MaintenanceDetailHeader({
    super.key,
    required this.itemName,
    required this.lastMaintenance,
    required this.imageWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        imageWidget,
        const SizedBox(height: 15),
        Text(
          itemName,
          style: const TextStyle(
            color: MyColors.secondary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Perawatan tiba!',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const Text(
          'Rawat barang ini sebelum rusak',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const SizedBox(height: 15),
        Text(
          'Perawatan Terakhir: $lastMaintenance',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
