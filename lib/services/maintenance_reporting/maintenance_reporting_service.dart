import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/report_period.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_chart.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_summary.dart';
import 'package:flutter_kita/repositories/maintenance_reporting/maintenance_reporting_repository.dart';

class MaintenanceReportingService {
  const MaintenanceReportingService({
    required MaintenanceReportingRepository repository,
  }) : _repository = repository;

  final MaintenanceReportingRepository _repository;

  Future<MaintenanceReportSummary> getSummary({required DateTimeRange period}) {
    return _repository.getSummary(period: period);
  }

  Future<List<MaintenanceReportChart>> getChart({
    required DateTimeRange period,
    required ReportPeriod reportPeriod,
  }) {
    return _repository.getChart(period: period, reportPeriod: reportPeriod);
  }

  Future<List<MaintenanceHistory>> getRecentHistory({int limit = 5}) {
    return _repository.getRecentHistory(limit: limit);
  }
}
