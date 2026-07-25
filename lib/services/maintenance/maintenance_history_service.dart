import 'package:flutter_kita/core/enum/maintenance_history_status.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_filter_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/repositories/maintenance/maintenance_repository.dart';

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
}
