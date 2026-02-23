import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceEmptyState extends StatelessWidget {
  const MaintenanceEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: MyColors.success),
            SizedBox(height: 16),
            Text(
              'Tidak ada perawatan hari ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Terima kasih atas kerja keras Anda.\nSemua perawatan telah diselesaikan atau belum dijadwalkan untuk hari ini.',
              style: TextStyle(fontSize: 14, color: MyColors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
