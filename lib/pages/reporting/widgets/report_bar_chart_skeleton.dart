import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class ReportBarChartSkeleton extends StatelessWidget {
  const ReportBarChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.greySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _BarPlaceholder(height: 90),
                _BarPlaceholder(height: 140),
                _BarPlaceholder(height: 110),
                _BarPlaceholder(height: 170),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (_) => Container(
                width: 35,
                height: 10,
                decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarPlaceholder extends StatelessWidget {
  final double height;

  const _BarPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: height,
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
    );
  }
}
