import 'package:flutter_kita/core/enum/maintenance_history_status.dart';

class MaintenanceHistoryFilter {
  final Set<MaintenanceHistoryStatus> statuses;
  final DateTime? startDate;
  final DateTime? endDate;

  const MaintenanceHistoryFilter({
    this.statuses = const {},
    this.startDate,
    this.endDate,
  });

  MaintenanceHistoryFilter copyWith({
    Set<MaintenanceHistoryStatus>? statuses,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MaintenanceHistoryFilter(
      statuses: statuses ?? this.statuses,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
