import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/maintenance_history_status.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_chart.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_summary.dart';
import 'package:flutter_kita/repositories/maintenance_reporting/maintenance_reporting_repository.dart';

class FirestoreMaintenanceReportingRepository
    implements MaintenanceReportingRepository {
  FirestoreMaintenanceReportingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<MaintenanceReportSummary> getSummary({
    required DateTimeRange period,
  }) async {
    final snapshot = await _firestore
        .collection('maintenance_history')
        .withConverter<MaintenanceHistory>(
          fromFirestore: MaintenanceHistory.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .where(
          'completedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(period.start),
        )
        .where(
          'completedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(period.end),
        )
        .get();

    int completed = 0;
    int skipped = 0;
    int quantity = 0;

    for (final doc in snapshot.docs) {
      final history = doc.data();

      switch (history.status) {
        case MaintenanceHistoryStatus.completed:
          completed++;
          break;

        case MaintenanceHistoryStatus.skipped:
          skipped++;
          break;
      }

      quantity += history.completedQuantity;
    }

    return MaintenanceReportSummary(
      total: snapshot.docs.length,
      completed: completed,
      skipped: skipped,
      quantity: quantity,
    );
  }

  Future<List<MaintenanceReportChart>> getChart({
    required DateTimeRange period,
  }) async {
    final snapshot = await _firestore
        .collection('maintenance_history')
        .withConverter<MaintenanceHistory>(
          fromFirestore: MaintenanceHistory.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .where(
          'completedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(period.start),
        )
        .where(
          'completedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(period.end),
        )
        .get();

    final histories = snapshot.docs
        .map((doc) => doc.data())
        .where(
          (history) => history.status == MaintenanceHistoryStatus.completed,
        )
        .toList();

    return _buildChartData(histories, period);
  }

  List<MaintenanceReportChart> _buildChartData(
    List<MaintenanceHistory> histories,
    DateTimeRange period,
  ) {
    final duration = period.end.difference(period.start).inDays + 1;

    if (duration <= 7) {
      return _buildDailyChart(histories, period);
    }

    if (duration <= 31) {
      return _buildWeeklyChart(histories, period);
    }

    if (duration <= 366) {
      return _buildMonthlyChart(histories, period);
    }

    return _buildMonthlyChart(histories, period);
  }

  List<MaintenanceReportChart> _buildDailyChart(
    List<MaintenanceHistory> histories,
    DateTimeRange period,
  ) {
    final Map<DateTime, int> grouped = {};

    final start = DateTime(
      period.start.year,
      period.start.month,
      period.start.day,
    );

    final end = DateTime(period.end.year, period.end.month, period.end.day);

    for (
      DateTime date = start;
      !date.isAfter(end);
      date = date.add(const Duration(days: 1))
    ) {
      grouped[date] = 0;
    }

    for (final history in histories) {
      final completedDate = history.completedAt.toDate();

      final key = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );

      grouped.update(key, (value) => value + 1, ifAbsent: () => 1);
    }

    return grouped.entries.map((entry) {
      final date = entry.key;

      return MaintenanceReportChart(
        label: '${date.day}/${date.month}',
        value: entry.value,
      );
    }).toList();
  }

  List<MaintenanceReportChart> _buildWeeklyChart(
    List<MaintenanceHistory> histories,
    DateTimeRange period,
  ) {
    final Map<int, int> grouped = {};

    // Tentukan jumlah minggu berdasarkan tanggal terakhir pada periode
    final totalWeeks = ((period.end.day - 1) ~/ 7) + 1;

    // Inisialisasi semua minggu dengan nilai 0
    for (int week = 1; week <= totalWeeks; week++) {
      grouped[week] = 0;
    }

    // Hitung jumlah maintenance completed per minggu
    for (final history in histories) {
      final date = history.completedAt.toDate();

      final week = ((date.day - 1) ~/ 7) + 1;

      grouped.update(week, (value) => value + 1, ifAbsent: () => 1);
    }

    return grouped.entries.map((entry) {
      final startDay = ((entry.key - 1) * 7) + 1;
      final endDay = (startDay + 6).clamp(1, period.end.day);

      return MaintenanceReportChart(
        label: '$startDay-$endDay',
        value: entry.value,
      );
    }).toList();
  }

  List<MaintenanceReportChart> _buildMonthlyChart(
    List<MaintenanceHistory> histories,
    DateTimeRange period,
  ) {
    final Map<DateTime, int> grouped = {};

    final start = DateTime(period.start.year, period.start.month);
    final end = DateTime(period.end.year, period.end.month);

    for (
      DateTime month = start;
      !month.isAfter(end);
      month = DateTime(month.year, month.month + 1)
    ) {
      grouped[month] = 0;
    }

    for (final history in histories) {
      final completedDate = history.completedAt.toDate();

      final key = DateTime(completedDate.year, completedDate.month);

      grouped.update(key, (value) => value + 1, ifAbsent: () => 1);
    }

    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return grouped.entries.map((entry) {
      return MaintenanceReportChart(
        label: monthNames[entry.key.month],
        value: entry.value,
      );
    }).toList();
  }
}
