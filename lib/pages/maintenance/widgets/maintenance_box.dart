import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/maintenance_status.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/details_maintenance_page.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceBox extends StatelessWidget {
  final Maintenance main;
  final MaintenanceStatus status;
  final String formattedDate;

  const MaintenanceBox({
    super.key,
    required this.main,
    required this.status,
    required this.formattedDate,
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

  Color _statusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.terlambat:
        return MyColors.error;
      case MaintenanceStatus.dalamProses:
        return MyColors.warning;
      case MaintenanceStatus.terjadwal:
        return MyColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = main.itemName;
    final intervalDays = main.intervalDays;
    final priority = main.priority;
    final initial = main.cycleInitialQuantity;
    final remaining = main.remainingQuantity;
    final completed = initial - remaining;

    final progress = initial > 0 ? (completed / initial).clamp(0.0, 1.0) : 0.0;

    final isInProgress = initial > 0 && remaining < initial && remaining > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsMaintenancePage(maintenanceId: main.id),
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
                      color: _priorityColor(priority).withValues(alpha: 0.5),
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
                main.partNumber != null && main.partNumber!.isNotEmpty
                    ? 'Nomor Part: ${main.partNumber}'
                    : 'Tipe Unit: ${main.typeUnit ?? '-'}',
                style: TextStyle(color: MyColors.black.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 12),

              // row icons date + interval + status
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: MyColors.black,
                  ),
                  const SizedBox(width: 6),
                  Text(formattedDate),
                  const SizedBox(width: 16),
                  const Icon(Icons.schedule, size: 18, color: MyColors.black),
                  const SizedBox(width: 6),
                  Text('Setiap $intervalDays hari'),
                  const Spacer(),
                ],
              ),
              // PROGRESS SECTION (jika dalam proses)
              if (isInProgress) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: MyColors.greySoft,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    MyColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$completed / $initial unit (${(progress * 100).toStringAsFixed(0)}%)",
                  style: const TextStyle(fontSize: 12),
                ),
              ],

              // status badge
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatStatus(status),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStatus(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.terlambat:
        return 'Terlambat';
      case MaintenanceStatus.dalamProses:
        return 'Dalam Proses';
      case MaintenanceStatus.terjadwal:
        return 'Terjadwal';
    }
  }
}
