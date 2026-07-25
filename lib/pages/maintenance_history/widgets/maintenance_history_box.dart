import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/maintenance_history_status.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/services/maintenance/maintenance_history_service.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceHistoryBox extends StatelessWidget {
  final MaintenanceHistory history;
  final VoidCallback? onTap;
  final MaintenanceHistoryService service;

  const MaintenanceHistoryBox({
    super.key,
    required this.history,
    this.onTap,
    required this.service,
  });

  Color _statusColor(MaintenanceHistoryStatus status) {
    switch (status) {
      case MaintenanceHistoryStatus.completed:
        return MyColors.success;
      case MaintenanceHistoryStatus.skipped:
        return MyColors.warning;
    }
  }

  String _statusText(MaintenanceHistoryStatus status) {
    switch (status) {
      case MaintenanceHistoryStatus.completed:
        return 'Completed';
      case MaintenanceHistoryStatus.skipped:
        return 'Skipped';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: MyColors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // TITLE + STATUS
              // =========================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      history.itemName,
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
                      color: service
                          .statusColor(history)
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      service.formatStatus(history),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              Text(
                history.partNumber != null && history.partNumber!.isNotEmpty
                    ? 'Nomor Part: ${history.partNumber}'
                    : 'Tipe Unit: -',
                style: TextStyle(color: MyColors.black.withValues(alpha: 0.7)),
              ),

              const SizedBox(height: 12),

              // =========================
              // DATE + CYCLE
              // =========================
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: MyColors.black,
                  ),
                  const SizedBox(width: 6),

                  Text(service.formatDate(history.completedAt.toDate())),

                  const SizedBox(width: 16),

                  const Icon(Icons.autorenew, size: 18, color: MyColors.black),
                  const SizedBox(width: 6),

                  Text(service.formatCycle(history.cycleNumber)),

                  const Spacer(),
                ],
              ),

              const SizedBox(height: 12),

              // =========================
              // TECHNICIAN
              // =========================
              Text(
                'Teknisi: ${history.userName}',
                style: TextStyle(color: MyColors.black.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
