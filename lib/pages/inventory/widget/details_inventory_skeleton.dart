import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_box.dart';
import 'package:flutter_kita/core/widgets/skeleton/skeleton_shimmer.dart';
import 'package:flutter_kita/styles/colors.dart';

class DetailsInventorySkeleton extends StatelessWidget {
  const DetailsInventorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        title: const Text('Detail Barang'),
        backgroundColor: MyColors.secondary,
      ),
      body: SkeletonShimmer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== TOP IMAGE AREA =====
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: MyColors.secondary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),

                  const Column(
                    children: [
                      SizedBox(height: 20),

                      SkeletonBox(width: 230, height: 230),

                      SizedBox(height: 12),

                      SkeletonBox(width: 180, height: 20),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ===== CONTENT =====
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _RowSkeleton(),
                    SizedBox(height: 10),
                    _RowSkeleton(),
                    SizedBox(height: 10),
                    _RowSkeleton(),
                    SizedBox(height: 10),
                    _RowSkeleton(),
                    SizedBox(height: 10),
                    _RowSkeleton(),
                    SizedBox(height: 10),
                    _RowSkeleton(),
                    SizedBox(height: 10),

                    // DESCRIPTION
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SkeletonBox(width: 120, height: 14),
                    ),
                    SizedBox(height: 6),
                    SkeletonBox(width: double.infinity, height: 12),
                    SizedBox(height: 4),
                    SkeletonBox(width: double.infinity, height: 12),

                    SizedBox(height: 20),

                    // BUTTON
                    SkeletonBox(width: double.infinity, height: 55),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonBox(width: 100, height: 14),
        SkeletonBox(width: 120, height: 14),
      ],
    );
  }
}
