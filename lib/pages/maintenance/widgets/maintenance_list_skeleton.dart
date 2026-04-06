import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_box.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceListSkeleton extends StatelessWidget {
  const MaintenanceListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return SkeletonShimmer(
          child: Container(
            padding: const EdgeInsets.all(16),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 TITLE + PRIORITY
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SkeletonBox(width: 160, height: 16)),
                    SizedBox(width: 8),
                    SkeletonBox(width: 60, height: 24),
                  ],
                ),

                SizedBox(height: 6),

                // 🔹 TYPE UNIT
                SkeletonBox(width: 120, height: 12),

                SizedBox(height: 12),

                // 🔹 DATE + INTERVAL
                Row(
                  children: [
                    SkeletonBox(width: 18, height: 18),
                    SizedBox(width: 6),
                    SkeletonBox(width: 80, height: 12),
                    SizedBox(width: 16),
                    SkeletonBox(width: 18, height: 18),
                    SizedBox(width: 6),
                    SkeletonBox(width: 100, height: 12),
                  ],
                ),

                SizedBox(height: 12),

                // 🔹 PROGRESS BAR (always shown in skeleton)
                SkeletonBox(width: double.infinity, height: 6),
                SizedBox(height: 6),
                SkeletonBox(width: 140, height: 12),

                SizedBox(height: 16),

                // 🔹 STATUS BADGE
                SkeletonBox(width: 80, height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
