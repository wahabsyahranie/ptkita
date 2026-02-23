import 'package:flutter/material.dart';

class RepairStatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const RepairStatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}
