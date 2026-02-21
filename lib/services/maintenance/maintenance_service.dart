import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
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

  Stream<List<Item>> streamItems() {
    return _repository.streamItems();
  }

  Stream<MaintenanceDetail?> streamMaintenanceDetail(String id) {
    return _repository.streamMaintenanceDetail(id);
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

  Future<void> saveMaintenance({required Maintenance maintenance}) async {
    final nextMaintenance = calculateNextMaintenance(
      lastMaintenance: maintenance.lastMaintenanceAt?.toDate(),
      intervalDays: maintenance.intervalDays,
    );

    final updatedMaintenance = Maintenance(
      id: maintenance.id,
      itemId: maintenance.itemId,
      itemName: maintenance.itemName,
      sku: maintenance.sku,
      intervalDays: maintenance.intervalDays,
      priority: maintenance.priority,
      status: maintenance.status,
      lastMaintenanceAt: maintenance.lastMaintenanceAt,
      nextMaintenanceAt: nextMaintenance,
      tasks: maintenance.tasks,
    );

    await _repository.save(updatedMaintenance);
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

    return formatDate(maintenance!.lastMaintenanceAt!.toDate());
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
