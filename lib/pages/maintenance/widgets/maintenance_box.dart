import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/details_maintenance_page.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceBox extends StatelessWidget {
  final Maintenance main;
  final String status;

  const MaintenanceBox({super.key, required this.main, required this.status});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';

    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

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

  Color _statusColor(String status) {
    return status == 'terlambat' ? MyColors.error : MyColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final name = main.itemName;
    final sku = main.sku ?? '-';
    final nextMaintenanceAt = _formatDate(main.nextMaintenanceAt?.toDate());
    final intervalDays = main.intervalDays;
    final priority = main.priority;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsMaintenancePage(maintenance: main),
          ),
        );
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title + priority badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _priorityColor(priority),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      priority[0].toUpperCase() + priority.substring(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 6),
              Text(
                sku,
                style: TextStyle(color: MyColors.black.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 12),

              // row icons date + interval + status
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: MyColors.greySoft,
                  ),
                  const SizedBox(width: 6),
                  Text(nextMaintenanceAt),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.schedule,
                    size: 18,
                    color: MyColors.greySoft,
                  ),
                  const SizedBox(width: 6),
                  Text('Setiap $intervalDays hari'),
                  const Spacer(),
                ],
              ),
              // status badge
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
