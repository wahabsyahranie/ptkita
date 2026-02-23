import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceCard extends StatelessWidget {
  final Stream<int> totalStream;
  final Stream<int> completedStream;

  const MaintenanceCard({
    super.key,
    required this.totalStream,
    required this.completedStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: totalStream,
      builder: (context, totalSnap) {
        if (!totalSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<int>(
          stream: completedStream,
          builder: (context, doneSnap) {
            if (!doneSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final total = totalSnap.data!;
            final done = doneSnap.data!;

            final hasMaintenance = total > 0;
            final hasPending = total > 0 && done < total;

            final progress = hasMaintenance ? done / total : 0.0;

            return _buildCard(
              context,
              total,
              done,
              progress,
              hasMaintenance,
              hasPending,
            );
          },
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    int total,
    int done,
    double progress,
    bool hasMaintenance,
    bool hasPending,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyColors.greySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perawatan Hari Ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$done / $total perawatan selesai',
                style: TextStyle(
                  color: hasPending ? MyColors.secondary : MyColors.black,
                  fontWeight: hasPending ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),

          // ✅ Progress hanya muncul jika ada maintenance
          if (hasMaintenance)
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: MyColors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      hasPending ? MyColors.secondary : MyColors.success,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasPending ? MyColors.secondary : MyColors.black,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
