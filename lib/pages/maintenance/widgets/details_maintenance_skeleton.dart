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
      body: SkeletonShimmer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 HEADER (image + title)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SkeletonBox(width: 120, height: 120), // image
                    SizedBox(height: 12),
                    SkeletonBox(width: 180, height: 16), // title
                  ],
                ),
              ),

              // 🔹 ALERT BOX
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SkeletonBox(width: double.infinity, height: 50),
              ),

              const SizedBox(height: 12),

              // 🔹 LAST MAINTENANCE
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBox(width: 18, height: 18),
                  SizedBox(width: 6),
                  SkeletonBox(width: 180, height: 12),
                ],
              ),

              const SizedBox(height: 30),

              // 🔹 META CARD
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SkeletonBox(width: double.infinity, height: 80),
              ),

              const SizedBox(height: 10),

              // 🔹 PROGRESS CARD
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SkeletonBox(width: double.infinity, height: 70),
              ),

              const SizedBox(height: 16),

              // 🔹 CHECKLIST TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SkeletonBox(width: 20, height: 20),
                    SizedBox(width: 8),
                    SkeletonBox(width: 160, height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 TASK LIST
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) {
                  return const SkeletonBox(width: double.infinity, height: 50);
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
