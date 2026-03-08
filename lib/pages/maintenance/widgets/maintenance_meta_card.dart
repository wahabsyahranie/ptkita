import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceMetaCard extends StatelessWidget {
  final int intervalDays;
  final String nextMaintenance;
  final String priority;

  const MaintenanceMetaCard({
    super.key,
    required this.intervalDays,
    required this.nextMaintenance,
    required this.priority,
  });

  Color _priorityColor(String p) {
    switch (p) {
      case 'tinggi':
        return MyColors.error;
      case 'sedang':
        return MyColors.warning;
      default:
        return MyColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(priority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 18),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _metaItem("Interval", "$intervalDays hari"),
          _divider(),
          _metaItem("Berikutnya", nextMaintenance),
          _divider(),
          Column(
            children: [
              const Text("Prioritas", style: TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  priority[0].toUpperCase() + priority.substring(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: MyColors.greySoft);
  }

  Widget _metaItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
