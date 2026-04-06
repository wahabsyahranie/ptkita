import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_box.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:flutter_kita/styles/colors.dart';

class InventoryListSkeleton extends StatelessWidget {
  const InventoryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return SkeletonShimmer(
          // ✅ pindah ke item
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MyColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                SkeletonBox(width: 40, height: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140, height: 14),
                      SizedBox(height: 4),
                      SkeletonBox(width: 80, height: 12),
                      SizedBox(height: 4),
                      SkeletonBox(width: 100, height: 12),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                SkeletonBox(width: 60, height: 20),
              ],
            ),
          ),
        );
      }, childCount: 6),
    );
  }
}
