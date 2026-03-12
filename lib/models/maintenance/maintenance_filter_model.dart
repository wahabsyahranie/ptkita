import 'package:flutter_kita/core/enum/maintenance_status.dart';

class MaintenanceFilter {
  final Set<MaintenanceStatus> statuses; // terlambat, terjadwal, dalam_proses
  final Set<String> priorities; // rendah, sedang, tinggi
  final Duration? timeRange; // 7d, 30d, 365d

  const MaintenanceFilter({
    this.statuses = const {},
    this.priorities = const {},
    this.timeRange,
  });
}
