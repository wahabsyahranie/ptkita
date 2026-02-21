import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_filter_model.dart';
import 'package:flutter_kita/repositories/maintenance/maintenance_repository.dart';

class MaintenanceService {
  final MaintenanceRepository _repository;

  MaintenanceService(this._repository);

  // =========================================================
  // ?? STREAM ??
  // =========================================================

  Stream<List<Maintenance>> streamMaintenance() {
    return _repository.streamMaintenance();
  }

  Stream<List<Map<String, dynamic>>> streamItems() {
    return _repository.streamItems();
  }

  // =========================================================
  // ?? STATUS (DERIVED - CLIENT SIDE) ??
  // =========================================================

  String computeStatus(Maintenance maintenance) {
    final now = DateTime.now();
    final next = maintenance.nextMaintenanceAt?.toDate();

    if (next == null) return 'terjadwal';

    return next.isBefore(now) ? 'terlambat' : 'terjadwal';
  }

  // =========================================================
  // ?? FILTER ??
  // =========================================================

  List<Maintenance> applyFilter(
    List<Maintenance> items,
    MaintenanceFilter? filter,
  ) {
    if (filter == null) return items;

    final now = DateTime.now();

    return items.where((m) {
      final next = m.nextMaintenanceAt?.toDate();
      if (next == null) return false;

      // 🔹 Filter Status
      if (filter.statuses.isNotEmpty) {
        final isLate = next.isBefore(now);
        final isScheduled = next.isAfter(now);

        final statusMatch =
            (filter.statuses.contains('terlambat') && isLate) ||
            (filter.statuses.contains('terjadwal') && isScheduled);

        if (!statusMatch) return false;
      }

      // 🔹 Filter Priority
      if (filter.priorities.isNotEmpty &&
          !filter.priorities.contains(m.priority)) {
        return false;
      }

      // 🔹 Filter Time Range
      if (filter.timeRange != null &&
          next.isAfter(now.add(filter.timeRange!))) {
        return false;
      }

      return true;
    }).toList();
  }

  // =========================================================
  // ?? SEARCH ??
  // =========================================================

  List<Maintenance> applySearch(List<Maintenance> items, String query) {
    if (query.isEmpty) return items;

    final q = query.toLowerCase();

    return items.where((m) {
      final name = m.itemName.toLowerCase();
      final sku = (m.sku ?? '').toLowerCase();
      return name.contains(q) || sku.contains(q);
    }).toList();
  }

  // =========================================================
  // ?? SAVE (CREATE / UPDATE) ??
  // =========================================================

  Future<void> saveMaintenance({
    required Map<String, dynamic> payload,
    String? id,
  }) async {
    if (id == null) {
      await _repository.addMaintenance(payload);
    } else {
      await _repository.updateMaintenance(id, payload);
    }
  }

  // =========================================================
  // ?? DELETE ??
  // =========================================================

  Future<void> deleteMaintenance(String id) {
    return _repository.deleteMaintenance(id);
  }

  // =========================================================
  // ?? FINISH MAINTENANCE ??
  // =========================================================

  Future<void> finishMaintenance(Maintenance maintenance) {
    return _repository.finishMaintenance(
      maintenance: maintenance,
      completedAt: DateTime.now(),
    );
  }

  // =========================================================
  // ?? IMAGE ??
  // =========================================================

  Future<String?> getItemImageUrl(String itemId) {
    return _repository.getItemImageUrl(itemId);
  }

  // =========================================================
  // ?? DATE LOGIC ??
  // =========================================================

  Timestamp calculateNextMaintenance({
    required DateTime? lastMaintenance,
    required int intervalDays,
  }) {
    final baseDate = lastMaintenance ?? DateTime.now();
    final nextDate = baseDate.add(Duration(days: intervalDays));
    return Timestamp.fromDate(nextDate);
  }

  DateTime? extractLastMaintenance(Maintenance? maintenance) {
    return maintenance?.lastMaintenanceAt?.toDate();
  }

  String formatLastMaintenance(Maintenance? maintenance) {
    if (maintenance?.lastMaintenanceAt == null) {
      return 'belum pernah';
    }

    final date = maintenance!.lastMaintenanceAt!.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // =========================================================
  // ?? PAYLOAD BUILDER ??
  // =========================================================

  Map<String, dynamic> buildPayload({
    required String itemId,
    required String itemName,
    required String? sku,
    required int intervalDays,
    required String priority,
    required DateTime? lastMaintenance,
    required List<Map<String, dynamic>> tasks,
  }) {
    final nextMaintenance = calculateNextMaintenance(
      lastMaintenance: lastMaintenance,
      intervalDays: intervalDays,
    );

    return {
      'active': true,
      'itemId': itemId,
      'itemName': itemName,
      'sku': sku,
      'intervalDays': intervalDays,
      'lastMaintenanceAt': lastMaintenance,
      'nextMaintenanceAt': nextMaintenance,
      'priority': priority,
      'tasks': tasks,
    };
  }
}
