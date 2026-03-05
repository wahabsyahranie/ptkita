import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceDetailHeader extends StatelessWidget {
  final String itemName;
  final Widget imageWidget;

  const MaintenanceDetailHeader({
    super.key,
    required this.itemName,
    required this.imageWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),

          /// IMAGE
          imageWidget,

          const SizedBox(height: 18),

          /// ITEM NAME
          Text(
            itemName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              // color: MyColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
