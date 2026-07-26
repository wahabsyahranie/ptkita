import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/report_period.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_chart.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_summary.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_bar_chart.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_period_selector.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_period_sheet.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_summary_grid.dart';
import 'package:flutter_kita/repositories/maintenance_reporting/firestore_maintenance_reporting_repository.dart';
import 'package:flutter_kita/services/maintenance_reporting/maintenance_reporting_service.dart';
import 'package:flutter_kita/styles/colors.dart';

class ReportingPage extends StatefulWidget {
  const ReportingPage({super.key});

  @override
  State<ReportingPage> createState() => _ReportingPageState();
}

class _ReportingPageState extends State<ReportingPage> {
  ReportPeriod _selectedPeriod = ReportPeriod.week;
  DateTimeRange? _customRange;

  MaintenanceReportSummary _summary = const MaintenanceReportSummary(
    total: 0,
    completed: 0,
    skipped: 3,
    quantity: 0,
  );
  List<MaintenanceReportChart> _chart = [];
  late final MaintenanceReportingService _reportingService;

  @override
  void initState() {
    super.initState();

    _reportingService = MaintenanceReportingService(
      repository: FirestoreMaintenanceReportingRepository(),
    );

    _loadSummary();
    _loadChart();
  }

  Future<void> _onPeriodChanged(ReportPeriod period) async {
    if (period == ReportPeriod.custom) {
      final result = await showModalBottomSheet<DateTimeRange>(
        context: context,
        backgroundColor: MyColors.white,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (_) => ReportPeriodSheet(initialRange: _customRange),
      );

      if (result == null) return;

      setState(() {
        _selectedPeriod = ReportPeriod.custom;
        _customRange = result;
      });

      await _loadSummary();
      await _loadChart();

      return;
    }

    setState(() {
      _selectedPeriod = period;
    });

    await _loadSummary();
    await _loadChart();
  }

  String _formatDate(DateTime date) {
    const months = [
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

    return '${date.day} ${months[date.month]} ${date.year}';
  }

  DateTimeRange get _activeDateRange {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case ReportPeriod.week:
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));

        final end = start.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );

        return DateTimeRange(start: start, end: end);

      case ReportPeriod.month:
        final start = DateTime(now.year, now.month, 1);

        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

        return DateTimeRange(start: start, end: end);

      case ReportPeriod.year:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );

      case ReportPeriod.custom:
        return _customRange ?? DateTimeRange(start: now, end: now);
    }
  }

  Future<void> _loadSummary() async {
    final summary = await _reportingService.getSummary(
      period: _activeDateRange,
    );

    if (!mounted) return;

    setState(() {
      _summary = summary;
    });
  }

  Future<void> _loadChart() async {
    final chart = await _reportingService.getChart(
      reportPeriod: _selectedPeriod,
      period: _activeDateRange,
    );

    if (!mounted) return;

    setState(() {
      _chart = chart;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        title: const Text("Reporting Maintenance"),
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: MyColors.black.withValues(alpha: 0.25),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Periode",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              ReportPeriodSelector(
                selectedPeriod: _selectedPeriod,
                onChanged: _onPeriodChanged,
              ),
              const SizedBox(height: 16),

              // Range tanggal
              Text(
                "${_formatDate(_activeDateRange.start)} - ${_formatDate(_activeDateRange.end)}",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Summary
              const Text(
                "Ringkasan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              ReportSummaryGrid(summary: _summary),

              const SizedBox(height: 24),

              // Chart
              const Text(
                "Grafik Maintenance",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              ReportBarChart(data: _chart),

              const SizedBox(height: 24),

              // History
              const Text(
                "Riwayat Maintenance",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 300, child: Placeholder()),
            ],
          ),
        ),
      ),
    );
  }
}
