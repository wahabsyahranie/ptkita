import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_box.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:flutter_kita/styles/colors.dart';

class RepairProgressCardSkeleton extends StatelessWidget {
  const RepairProgressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MyColors.greySoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            SkeletonBox(width: 180, height: 16),

            SizedBox(height: 8),

            // SUBTITLE
            SkeletonBox(width: 120, height: 12),

            SizedBox(height: 20),

            // ROW 1
            _ProgressRowSkeleton(),

            SizedBox(height: 16),

            // ROW 2
            _ProgressRowSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _ProgressRowSkeleton extends StatelessWidget {
  const _ProgressRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        // ICON
        SkeletonBox(width: 20, height: 20),

        SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE + VALUE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: 120, height: 14),
                  SkeletonBox(width: 30, height: 14),
                ],
              ),
              SizedBox(height: 6),

              // PROGRESS BAR
              SkeletonBox(width: double.infinity, height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
