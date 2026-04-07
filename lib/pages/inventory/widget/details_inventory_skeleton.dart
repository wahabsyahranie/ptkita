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
              // ======== TOP IMAGE ========
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MyColors.secondary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const Column(
                    children: [
                      SizedBox(height: 10),
                      SkeletonBox(width: 230, height: 230),
                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SkeletonBox(width: double.infinity, height: 20),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ========= BODY =========
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _RowSkeleton(),
                    _LineSkeleton(),
                    SizedBox(height: 10),

                    _RowSkeleton(),
                    _LineSkeleton(),
                    SizedBox(height: 10),

                    _RowSkeleton(),
                    _LineSkeleton(),
                    SizedBox(height: 10),

                    _RowSkeleton(),
                    _LineSkeleton(),
                    SizedBox(height: 10),

                    _RowSkeleton(),
                    _LineSkeleton(),
                    SizedBox(height: 10),

                    // PART NUMBER (ALWAYS ADA di skeleton)
                    _RowSkeleton(),
                    _LineSkeleton(),
                    SizedBox(height: 10),

                    _RowSkeleton(),
                    _LineSkeleton(),
                    SizedBox(height: 10),

                    _RowSkeleton(),
                    _LineSkeleton(),
                    SizedBox(height: 10),

                    // ===== MOVEMENT =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBox(width: 120, height: 14),
                        SkeletonBox(width: 80, height: 30),
                      ],
                    ),
                    _LineSkeleton(),
                    SizedBox(height: 10),

                    // ===== DESKRIPSI =====
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SkeletonBox(width: 120, height: 14),
                    ),
                    SizedBox(height: 6),
                    SkeletonBox(width: double.infinity, height: 14),
                    SizedBox(height: 4),
                    SkeletonBox(width: double.infinity, height: 14),
                    _LineSkeleton(),

                    SizedBox(height: 16),

                    // ===== AUDIT (FAKE EXPANSION TILE) =====
                    Row(
                      children: [
                        SkeletonBox(width: 16, height: 16),
                        SizedBox(width: 6),
                        SkeletonBox(width: 140, height: 14),
                      ],
                    ),

                    SizedBox(height: 30),

                    // ===== BUTTON =====
                    SkeletonBox(width: double.infinity, height: 55),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== ROW =====
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

// ===== LINE =====
class _LineSkeleton extends StatelessWidget {
  const _LineSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: SkeletonBox(width: double.infinity, height: 1),
    );
  }
}
