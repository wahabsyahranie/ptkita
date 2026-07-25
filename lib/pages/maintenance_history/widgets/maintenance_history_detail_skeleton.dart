import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceHistoryDetailSkeleton extends StatelessWidget {
  const MaintenanceHistoryDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        title: const Text("Detail Riwayat"),
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _headerSkeleton(),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (int i = 0; i < 7; i++) ...[
                    _rowSkeleton(),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 20),

                  _buttonSkeleton(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: MyColors.white,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(height: 24, width: 180),

              const SizedBox(height: 12),

              _box(height: 16, width: 140),

              const SizedBox(height: 20),

              _box(height: 34, width: 150),

              const SizedBox(height: 20),

              _box(height: 18, width: 110),

              const SizedBox(height: 12),

              _box(height: 18, width: 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_box(height: 16, width: 120), _box(height: 16, width: 100)],
    );
  }

  Widget _buttonSkeleton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: MyColors.greySoft.withValues(alpha: .25),
        borderRadius: BorderRadius.circular(40),
      ),
    );
  }

  Widget _box({required double height, required double width}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MyColors.greySoft.withValues(alpha: .25),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
