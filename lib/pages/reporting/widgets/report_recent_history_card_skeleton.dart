import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class ReportRecentHistoryCardSkeleton extends StatelessWidget {
  const ReportRecentHistoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MyColors.greySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: MyColors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 110,
                height: 12,
                decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: 20),

              Container(
                width: 70,
                height: 12,
                decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
