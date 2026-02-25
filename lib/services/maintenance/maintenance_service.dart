import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_filter_model.dart';
import 'package:flutter_kita/repositories/maintenance/maintenance_repository.dart';

class MaintenanceService {
  final MaintenanceRepository _repository;

  MaintenanceService(this._repository);

  // =========================================================
  // ====================== STREAM LIST ======================
  // =========================================================

  Stream<List<Maintenance>> streamMaintenance({
    MaintenanceFilter? filter,
    String searchQuery = '',
  }) {
    return _repository.streamMaintenance().map((items) {
      final filtered = _applyFilter(items, filter);
      return _applySearch(filtered, searchQuery);
    });
  }

  Stream<List<Item>> streamItems() {
    return _repository.streamItems();
  }

  Stream<MaintenanceDetail?> streamMaintenanceDetail(String id) {
    return _repository.streamMaintenanceDetail(id);
  }

  // =========================================================
  // ====================== STATUS ===========================
  // =========================================================

  String computeStatus(Maintenance maintenance) {
    final now = DateTime.now();
    final next = maintenance.nextMaintenanceAt?.toDate();

    if (next == null) return 'terjadwal';

    // Ambil hanya tanggal (buang jam)
    final today = DateTime(now.year, now.month, now.day);
    final nextDate = DateTime(next.year, next.month, next.day);

    if (nextDate.isBefore(today)) {
      return 'terlambat';
    }

    return 'terjadwal';
  }

  // =========================================================
  // ====================== FILTER ===========================
  // =========================================================

  List<Maintenance> _applyFilter(
    List<Maintenance> items,
    MaintenanceFilter? filter,
  ) {
    if (filter == null) return items;

    final now = DateTime.now();

    return items.where((m) {
      final next = m.nextMaintenanceAt?.toDate();
      if (next == null) return false;

      // Status filter
      if (filter.statuses.isNotEmpty) {
        final status = computeStatus(m);
        if (!filter.statuses.contains(status)) return false;
      }

      // Priority filter
      if (filter.priorities.isNotEmpty &&
          !filter.priorities.contains(m.priority)) {
        return false;
      }

      // Time range filter
      // Time range filter (berbasis hari kalender)
      if (filter.timeRange != null) {
        final startOfToday = DateTime(now.year, now.month, now.day);
        final endOfRange = startOfToday.add(filter.timeRange!);

        // next harus di dalam range kalender
        if (next.isBefore(startOfToday) || !next.isBefore(endOfRange)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // =========================================================
  // ====================== SEARCH ===========================
  // =========================================================

  List<Maintenance> _applySearch(List<Maintenance> items, String query) {
    if (query.isEmpty) return items;

    final q = query.toLowerCase();

    return items.where((m) {
      final name = m.itemName.toLowerCase();
      final sku = (m.sku ?? '').toLowerCase();
      return name.contains(q) || sku.contains(q);
    }).toList();
  }

  // =========================================================
  // ====================== SAVE =============================
  // =========================================================

  Future<void> saveMaintenance({required Maintenance maintenance}) async {
    final nextMaintenance = _calculateNextMaintenance(
      lastMaintenance: maintenance.lastMaintenanceAt?.toDate(),
      intervalDays: maintenance.intervalDays,
    );

    final updatedMaintenance = maintenance.copyWith(
      status: maintenance.status.isEmpty ? 'pending' : maintenance.status,
      nextMaintenanceAt: nextMaintenance,
    );

    await _repository.save(updatedMaintenance);
  }

  // =========================================================
  // ====================== DELETE ===========================
  // =========================================================

  Future<void> deleteById(String id) {
    return _repository.deleteMaintenance(id);
  }

  // =========================================================
  // ====================== FINISH ===========================
  // =========================================================

  Future<void> finishMaintenance(Maintenance maintenance) async {
    final now = DateTime.now();

    final updated = maintenance.copyWith(
      status: 'selesai',
      lastMaintenanceAt: Timestamp.fromDate(now),
      nextMaintenanceAt: _calculateNextMaintenance(
        lastMaintenance: now,
        intervalDays: maintenance.intervalDays,
      ),
    );

    await _repository.save(updated);
  }

  // =========================================================
  // ====================== DATE LOGIC =======================
  // =========================================================

  Timestamp _calculateNextMaintenance({
    required DateTime? lastMaintenance,
    required int intervalDays,
  }) {
    final baseDate = lastMaintenance ?? DateTime.now();
    final nextDate = baseDate.add(Duration(days: intervalDays));
    return Timestamp.fromDate(nextDate);
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
