import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/report_period.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_chart.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_summary.dart';

abstract class MaintenanceReportingRepository {
  Future<MaintenanceReportSummary> getSummary({required DateTimeRange period});

  Future<List<MaintenanceReportChart>> getChart({
    required DateTimeRange period,
    required ReportPeriod reportPeriod,
  });

  Future<List<MaintenanceHistory>> getRecentHistory({int limit = 5});
}
