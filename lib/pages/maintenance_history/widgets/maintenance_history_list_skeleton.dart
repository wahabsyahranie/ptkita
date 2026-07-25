import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_box.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceHistoryListSkeleton extends StatelessWidget {
  const MaintenanceHistoryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return SkeletonShimmer(
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            color: MyColors.white,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // TITLE + STATUS
                  // =========================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: SkeletonBox(width: 170, height: 16)),
                      SizedBox(width: 10),
                      SkeletonBox(width: 80, height: 24),
                    ],
                  ),

                  SizedBox(height: 8),

                  // =========================
                  // PART NUMBER
                  // =========================
                  SkeletonBox(width: 150, height: 12),

                  SizedBox(height: 14),

                  // =========================
                  // DATE + CYCLE
                  // =========================
                  Row(
                    children: [
                      SkeletonBox(width: 18, height: 18),
                      SizedBox(width: 6),
                      SkeletonBox(width: 95, height: 12),

                      SizedBox(width: 18),

                      SkeletonBox(width: 18, height: 18),
                      SizedBox(width: 6),
                      SkeletonBox(width: 70, height: 12),
                    ],
                  ),

                  SizedBox(height: 12),

                  // =========================
                  // TECHNICIAN
                  // =========================
                  Row(
                    children: [
                      SkeletonBox(width: 18, height: 18),
                      SizedBox(width: 6),
                      SkeletonBox(width: 140, height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
