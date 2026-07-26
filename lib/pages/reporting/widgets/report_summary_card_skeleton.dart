import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class ReportSummaryCardSkeleton extends StatelessWidget {
  const ReportSummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.greySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: MyColors.white,
              shape: BoxShape.circle,
            ),
          ),

          const Spacer(),

          Container(
            width: 70,
            height: 12,
            decoration: BoxDecoration(
              color: MyColors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: MyColors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}