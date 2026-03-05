import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/core/enum/maintenance_status.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_filter_model.dart';
import 'package:flutter_kita/models/user/user_model.dart';
import 'package:flutter_kita/repositories/maintenance/maintenance_repository.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/services/user/user_service.dart';

class MaintenanceException implements Exception {
  final String message;

  MaintenanceException(this.message);

  @override
  String toString() => message;
}

class MaintenanceService {
  final MaintenanceRepository _repository;
  final InventoryService _inventoryService;
  final UserService _userService;

  MaintenanceService(
    this._repository,
    this._inventoryService,
    this._userService,
  );

  // =========================================================
  // ====================== STREAM LIST ======================
  // =========================================================

  Stream<List<Maintenance>> streamMaintenance({
    MaintenanceFilter? filter,
    String searchQuery = '',
  }) {
    return _repository.streamMaintenance().map((items) {
      final filtered = _applyFilter(items, filter);
      final searched = _applySearch(filtered, searchQuery);

      searched.sort((a, b) {
        final statusA = computeStatus(a);
        final statusB = computeStatus(b);

        // 1️⃣ Dalam Proses paling atas
        if (statusA == MaintenanceStatus.dalamProses &&
            statusB != MaintenanceStatus.dalamProses) {
          return -1;
        }
        if (statusB == MaintenanceStatus.dalamProses &&
            statusA != MaintenanceStatus.dalamProses) {
          return 1;
        }

        // 2️⃣ Terlambat berikutnya
        if (statusA == MaintenanceStatus.terlambat &&
            statusB != MaintenanceStatus.terlambat) {
          return -1;
        }
        if (statusB == MaintenanceStatus.terlambat &&
            statusA != MaintenanceStatus.terlambat) {
          return 1;
        }

        // 3️⃣ Sisanya berdasarkan tanggal
        final nextA = a.nextMaintenanceAt?.toDate() ?? DateTime(2100);
        final nextB = b.nextMaintenanceAt?.toDate() ?? DateTime(2100);

        return nextA.compareTo(nextB);
      });

      return searched;
    });
  }

  Stream<List<Item>> streamItems() {
    return _repository.streamItems();
  }

  Stream<MaintenanceDetailView?> streamMaintenanceDetail(String id) {
    return _repository.streamMaintenanceDetail(id).map((detail) {
      if (detail == null) return null;

      final item = detail.item;
      if (item == null) return null;

      final maintenance = detail.maintenance;

      final initial = maintenance.cycleInitialQuantity;
      final remaining = maintenance.remainingQuantity;
      final completed = initial - remaining;

      final progress = initial > 0
          ? (completed / initial).clamp(0.0, 1.0)
          : 0.0;

      final imageProvider = _inventoryService.resolveImage(item);

      return MaintenanceDetailView(
        maintenance: maintenance,
        imageProvider: imageProvider,
        initialQuantity: initial,
        remainingQuantity: remaining,
        completedQuantity: completed,
        progress: progress,
      );
    });
  }

  // =========================================================
  // ====================== STATUS ===========================
  // =========================================================
  MaintenanceStatus computeStatus(Maintenance maintenance) {
    final now = DateTime.now();
    final next = maintenance.nextMaintenanceAt?.toDate();

    final initial = maintenance.cycleInitialQuantity;
    final remaining = maintenance.remainingQuantity;

    // DALAM PROSES (prioritas tertinggi)
    if (remaining < initial && remaining > 0) {
      return MaintenanceStatus.dalamProses;
    }

    if (next == null) return MaintenanceStatus.terjadwal;

    final today = DateTime(now.year, now.month, now.day);
    final nextDate = DateTime(next.year, next.month, next.day);

    final isDueOrPast = !today.isBefore(nextDate);

    if (isDueOrPast && remaining == initial) {
      return MaintenanceStatus.terlambat;
    }

    return MaintenanceStatus.terjadwal;
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
    final isCreate = maintenance.id.isEmpty;

    if (isCreate) {
      final now = DateTime.now();

      // 1️⃣ Ambil stok item
      final item = await _inventoryService
          .streamItemById(maintenance.itemId)
          .first;

      final currentStock = item?.stock ?? 0;

      // 2️⃣ Hitung next maintenance
      final nextMaintenance = Timestamp.fromDate(
        now.add(Duration(days: maintenance.intervalDays)),
      );

      // 3️⃣ Buat maintenance dengan snapshot siklus
      final newMaintenance = maintenance.copyWith(
        nextMaintenanceAt: nextMaintenance,
        cycleInitialQuantity: currentStock,
        remainingQuantity: currentStock,
      );

      await _repository.save(newMaintenance);
    } else {
      await _repository.save(maintenance);
    }
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

  Future<bool> finishMaintenance({
    required Maintenance maintenance,
    required int completedQuantity,
  }) async {
    final item = await _inventoryService
        .streamItemById(maintenance.itemId)
        .first;

    final currentStock = item?.stock ?? 0;

    if (maintenance.remainingQuantity == 0) {
      throw MaintenanceException("Maintenance sudah selesai.");
    }

    final now = DateTime.now();
    final completedTimestamp = Timestamp.fromDate(now);

    // ========================================
    // SAFETY GUARD UNTUK DATA LAMA
    // ========================================
    if (maintenance.cycleInitialQuantity == 0 &&
        maintenance.remainingQuantity == 0) {
      final snapshotUpdate = {
        'cycleInitialQuantity': currentStock,
        'remainingQuantity': currentStock,
      };

      await _repository.commitMaintenanceBatch(
        maintenanceId: maintenance.id,
        maintenanceUpdate: snapshotUpdate,
        logData: {}, // tidak buat log
      );

      throw MaintenanceException(
        "Snapshot siklus diperbarui. Silakan ulangi maintenance.",
      );
    }

    // ==============================
    // VALIDASI
    // ==============================

    if (completedQuantity <= 0) {
      throw MaintenanceException("Jumlah harus lebih dari 0");
    }

    if (completedQuantity > maintenance.remainingQuantity) {
      throw MaintenanceException("Jumlah tidak boleh melebihi sisa");
    }

    final newRemaining = maintenance.remainingQuantity - completedQuantity;

    // ==============================
    // SIAPKAN LOG
    // ==============================

    final UserModel? currentUser = await _userService.currentUserProfile.first;

    if (currentUser == null) {
      throw Exception("User tidak ditemukan");
    }

    final logData = {
      'maintenanceId': maintenance.id,
      'itemId': maintenance.itemId,
      'completedQuantity': completedQuantity,
      'completedAt': completedTimestamp,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': currentUser.id,
      'userName': currentUser.name,
      'action': newRemaining > 0
          ? 'maintenance_partial'
          : 'maintenance_complete',
    };

    // ==============================
    // CASE 1: BELUM SELESAI SIKLUS
    // ==============================

    if (newRemaining > 0) {
      final maintenanceUpdate = {'remainingQuantity': newRemaining};

      await _repository.commitMaintenanceBatch(
        maintenanceId: maintenance.id,
        maintenanceUpdate: maintenanceUpdate,
        logData: logData,
      );

      return false; // siklus belum selesai
    }

    // ==============================
    // CASE 2: SIKLUS SELESAI
    // ==============================
    final baseDate = maintenance.nextMaintenanceAt?.toDate() ?? now;

    final nextMaintenanceDate = baseDate.add(
      Duration(days: maintenance.intervalDays),
    );

    final maintenanceUpdate = {
      'lastMaintenanceAt': completedTimestamp,
      'nextMaintenanceAt': Timestamp.fromDate(nextMaintenanceDate),
      'cycleInitialQuantity': currentStock,
      'remainingQuantity': currentStock,
    };

    await _repository.commitMaintenanceBatch(
      maintenanceId: maintenance.id,
      maintenanceUpdate: maintenanceUpdate,
      logData: logData,
    );

    return true; // siklus selesai
  }

  // =========================================================
  // ====================== DATE LOGIC =======================
  // =========================================================

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
