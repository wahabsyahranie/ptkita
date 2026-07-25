import 'dart:ui';

import 'package:flutter_kita/core/enum/maintenance_history_status.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_filter_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/repositories/maintenance/maintenance_repository.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceHistoryService {
  final MaintenanceRepository _repository;

  MaintenanceHistoryService(this._repository);

  Stream<List<MaintenanceHistory>> streamHistory({
    MaintenanceHistoryFilter? filter,
    String searchQuery = '',
  }) {
    return _repository.streamMaintenanceHistory().map((histories) {
      var results = histories;

      results = _filterByStatus(results, filter);
      results = _filterByKeyword(results, searchQuery);
      results = _filterByDate(results, filter);

      return results;
    });
  }

  Stream<MaintenanceHistory?> streamHistoryDetail(String id) {
    return _repository.streamMaintenanceHistoryDetail(id);
  }

  List<MaintenanceHistory> _filterByStatus(
    List<MaintenanceHistory> histories,
    MaintenanceHistoryFilter? filter,
  ) {
    if (filter == null || filter.statuses.isEmpty) {
      return histories;
    }

    return histories.where((history) {
      return filter.statuses.contains(history.status);
    }).toList();
  }

  List<MaintenanceHistory> _filterByKeyword(
    List<MaintenanceHistory> histories,
    String? keyword,
  ) {
    if (keyword == null || keyword.trim().isEmpty) {
      return histories;
    }

    final query = keyword.trim().toLowerCase();

    return histories.where((history) {
      final itemName = history.itemName.toLowerCase();
      final partNumber = history.partNumber?.toLowerCase() ?? '';
      final userName = history.userName.toLowerCase();

      return itemName.contains(query) ||
          partNumber.contains(query) ||
          userName.contains(query);
    }).toList();
  }

  List<MaintenanceHistory> _filterByDate(
    List<MaintenanceHistory> histories,
    MaintenanceHistoryFilter? filter,
  ) {
    if (filter == null) {
      return histories;
    }

    if (filter.startDate == null && filter.endDate == null) {
      return histories;
    }

    return histories.where((history) {
      final completedDate = history.completedAt.toDate();

      if (filter.startDate != null &&
          completedDate.isBefore(filter.startDate!)) {
        return false;
      }

      if (filter.endDate != null && completedDate.isAfter(filter.endDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  // =========================================================
  // ====================== FORMATTER =========================
  // =========================================================
  String formatDate(DateTime? date) {
    if (date == null) return '-';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatStatus(MaintenanceHistory history) {
    if (history.status == MaintenanceHistoryStatus.skipped) {
      return "Maintenance Dilewati";
    }

    final lateDays = calculateLateDays(history);

    if (lateDays == 0) {
      return "Selesai Tepat Waktu";
    }

    if (lateDays == 1) {
      return "Terlambat 1 Hari";
    }

    return "Terlambat $lateDays Hari";
  }

  String formatCycle(int cycleNumber) {
    return 'Siklus $cycleNumber';
  }

  Color statusColor(MaintenanceHistory history) {
    if (history.status == MaintenanceHistoryStatus.skipped) {
      return MyColors.warning;
    }

    final lateDays = calculateLateDays(history);

    if (lateDays == 0) {
      return MyColors.success;
    }

    return MyColors.error;
  }

  String formatLateDays(MaintenanceHistory history) {
    if (history.status == MaintenanceHistoryStatus.skipped) {
      return '-';
    }

    final lateDays = calculateLateDays(history);

    if (lateDays == 0) {
      return 'Tidak Terlambat';
    }

    if (lateDays == 1) {
      return '1 Hari';
    }

    return '$lateDays Hari';
  }

  int calculateLateDays(MaintenanceHistory history) {
    if (history.status == MaintenanceHistoryStatus.skipped) {
      return 0;
    }

    final scheduled = history.scheduledAt?.toDate();
    if (scheduled == null) return 0;

    final completed = history.completedAt.toDate();

    final scheduledDate = DateTime(
      scheduled.year,
      scheduled.month,
      scheduled.day,
    );

    final completedDate = DateTime(
      completed.year,
      completed.month,
      completed.day,
    );

    final diff = completedDate.difference(scheduledDate).inDays;

    return diff > 0 ? diff : 0;
  }
}
