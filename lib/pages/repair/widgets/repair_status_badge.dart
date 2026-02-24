import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class RepairStatusBadge extends StatelessWidget {
  final String text;

  const RepairStatusBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();

    Color baseColor;

    if (lower == 'selesai') {
      baseColor = MyColors.success;
    } else if (lower == 'garansi') {
      baseColor = MyColors.info;
    } else {
      baseColor = MyColors.secondary; // proses / lainnya
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: baseColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
