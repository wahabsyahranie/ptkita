import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class InfoSheet extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;

  const InfoSheet({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'Mengerti',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: MyColors.greySoft,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 24),

          Text(message, style: const TextStyle(fontSize: 15, height: 1.6)),

          const SizedBox(height: 28),

          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MyColors.secondary,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 18,
                  color: MyColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
