import 'package:flutter_kita/core/enum/maintenance_history_date_filter.dart';
import 'package:flutter_kita/core/enum/maintenance_history_status.dart';

class MaintenanceHistoryFilter {
  final Set<MaintenanceHistoryStatus> statuses;
  final DateTime? startDate;
  final DateTime? endDate;
  final MaintenanceHistoryDateFilter dateFilter;

  const MaintenanceHistoryFilter({
    this.statuses = const {},
    this.startDate,
    this.endDate,
    this.dateFilter = MaintenanceHistoryDateFilter.all,
  });

  MaintenanceHistoryFilter copyWith({
    Set<MaintenanceHistoryStatus>? statuses,
    MaintenanceHistoryDateFilter? dateFilter,
    Object? startDate = _noChange,
    Object? endDate = _noChange,
  }) {
    return MaintenanceHistoryFilter(
      statuses: statuses ?? this.statuses,
      dateFilter: dateFilter ?? this.dateFilter,
      startDate: identical(startDate, _noChange)
          ? this.startDate
          : startDate as DateTime?,
      endDate: identical(endDate, _noChange)
          ? this.endDate
          : endDate as DateTime?,
    );
  }

  static const _noChange = Object();
}
