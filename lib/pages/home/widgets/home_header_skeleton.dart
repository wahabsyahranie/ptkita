import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_box.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_circle.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_shimmer.dart';

class HomeHeaderSkeleton extends StatelessWidget {
  const HomeHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TEXT AREA
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 120, height: 14),
              SizedBox(height: 8),
              SkeletonBox(width: 160, height: 16),
            ],
          ),

          // AVATAR
          SkeletonCircle(size: 52), // radius 26 = diameter 52
        ],
      ),
    );
  }
}
