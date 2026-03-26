import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_box.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_circle.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:flutter_kita/styles/colors.dart';

class StatisticCardsSkeleton extends StatelessWidget {
  const StatisticCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _CardSkeleton()),
        SizedBox(width: 15),
        Expanded(child: _CardSkeleton()),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: MyColors.greySoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON AREA
            Align(
              alignment: Alignment.topRight,
              child: SkeletonCircle(size: 36),
            ),

            SizedBox(height: 10),

            // VALUE
            SkeletonBox(width: 50, height: 24),

            SizedBox(height: 15),

            // TITLE
            SkeletonBox(width: 90, height: 14),

            SizedBox(height: 6),

            // SUBTITLE
            SkeletonBox(width: 120, height: 12),
          ],
        ),
      ),
    );
  }
}
