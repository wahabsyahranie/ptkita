import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceProgressCard extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;

  const MaintenanceProgressCard({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE + PERCENT
          Row(
            children: [
              const Text(
                "Progress Perawatan",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const Spacer(),
              Text(
                "$percent%",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// PROGRESS BAR
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: MyColors.greySoft,
            valueColor: const AlwaysStoppedAnimation(MyColors.secondary),
          ),

          const SizedBox(height: 8),

          /// DETAIL TEXT
          Text(
            "$completed / $total unit selesai",
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
