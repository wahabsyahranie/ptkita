import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_box.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:flutter_kita/styles/colors.dart';

class DetailsMaintenanceSkeleton extends StatelessWidget {
  const DetailsMaintenanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SkeletonShimmer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= HEADER =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(height: 12),

                    // IMAGE (MATCH EXACT)
                    SkeletonBox(width: 160, height: 160),

                    SizedBox(height: 18),

                    // TITLE
                    SkeletonBox(width: 200, height: 20),

                    SizedBox(height: 8),
                  ],
                ),
              ),

              // ================= ALERT =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SkeletonBox(width: double.infinity, height: 60),
              ),

              const SizedBox(height: 12),

              // ================= LAST MAINTENANCE =================
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonBox(width: 18, height: 18),
                    SizedBox(width: 6),
                    SkeletonBox(width: 220, height: 14),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= META CARD =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SkeletonBox(width: double.infinity, height: 90),
              ),

              const SizedBox(height: 10),

              // ================= PROGRESS CARD =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SkeletonBox(width: double.infinity, height: 80),
              ),

              const SizedBox(height: 6),

              // ================= TITLE CHECKLIST =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    SkeletonBox(width: 20, height: 20),
                    SizedBox(width: 8),
                    SkeletonBox(width: 180, height: 16),
                  ],
                ),
              ),

              // ================= TASK LIST =================
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (_, __) => const MaintenanceTaskCardSkeleton(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class MaintenanceTaskCardSkeleton extends StatelessWidget {
  const MaintenanceTaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MyColors.greySoft),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON / NUMBER CIRCLE
          SkeletonBox(width: 40, height: 40),

          SizedBox(width: 14),

          // TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 16),

                SizedBox(height: 6),

                SkeletonBox(width: double.infinity, height: 14),

                SizedBox(height: 6),

                SkeletonBox(width: 120, height: 14),

                SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: SkeletonBox(width: 70, height: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
