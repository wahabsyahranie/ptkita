import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/maintenance_status.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceAlertBox extends StatelessWidget {
  final MaintenanceStatus status;
  final String nextMaintenance;

  const MaintenanceAlertBox({
    super.key,
    required this.status,
    required this.nextMaintenance,
  });

  Color _backgroundColor() {
    switch (status) {
      case MaintenanceStatus.terlambat:
        return MyColors.error.withValues(alpha: 0.12);
      case MaintenanceStatus.dalamProses:
        return MyColors.warning.withValues(alpha: 0.12);
      case MaintenanceStatus.terjadwal:
      return MyColors.info.withValues(alpha: 0.12);
    }
  }

  Color _borderColor() {
    switch (status) {
      case MaintenanceStatus.terlambat:
        return MyColors.error;
      case MaintenanceStatus.dalamProses:
        return MyColors.warning;
      case MaintenanceStatus.terjadwal:
      return MyColors.info;
    }
  }

  IconData _icon() {
    switch (status) {
      case MaintenanceStatus.terlambat:
        return Icons.warning_amber_rounded;
      case MaintenanceStatus.dalamProses:
        return Icons.build_circle_outlined;
      case MaintenanceStatus.terjadwal:
      return Icons.event_available;
    }
  }

  String _title() {
    switch (status) {
      case MaintenanceStatus.terlambat:
        return "Maintenance Terlambat";
      case MaintenanceStatus.dalamProses:
        return "Maintenance Sedang Berjalan";
      case MaintenanceStatus.terjadwal:
      return "Maintenance Terjadwal";
    }
  }

  String _description() {
    switch (status) {
      case MaintenanceStatus.terlambat:
        return "Perawatan seharusnya dilakukan pada $nextMaintenance";
      case MaintenanceStatus.dalamProses:
        return "Checklist sedang dikerjakan";
      case MaintenanceStatus.terjadwal:
      return "Perawatan berikutnya pada $nextMaintenance";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor(), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(), color: _borderColor()),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _borderColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _description(),
                  style: TextStyle(fontSize: 12, color: _borderColor()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
