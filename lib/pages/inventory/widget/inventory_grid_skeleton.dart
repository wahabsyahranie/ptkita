import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_box.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:flutter_kita/styles/colors.dart';

class InventoryGridSkeleton extends StatelessWidget {
  const InventoryGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        return SkeletonShimmer(
          // ✅ PINDAH KE SINI
          child: Container(
            decoration: BoxDecoration(
              color: MyColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: MyColors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  SkeletonBox(width: double.infinity, height: 90),
                  SizedBox(height: 8),
                  SkeletonBox(width: 100, height: 14),
                  SizedBox(height: 4),
                  SkeletonBox(width: 80, height: 12),
                  SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SkeletonBox(width: 60, height: 12),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SkeletonBox(width: 80, height: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      }, childCount: 6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
    );
  }
}
