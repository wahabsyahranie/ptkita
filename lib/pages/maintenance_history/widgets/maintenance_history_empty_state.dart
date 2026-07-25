import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceHistoryEmptyState extends StatelessWidget {
  const MaintenanceHistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: MyColors.greySoft),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat perawatan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Riwayat perawatan akan muncul setelah teknisi menyelesaikan atau melewati proses perawatan.',
              style: TextStyle(fontSize: 14, color: MyColors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
