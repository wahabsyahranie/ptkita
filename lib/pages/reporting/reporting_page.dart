import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/report_period.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_chart.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_summary.dart';
import 'package:flutter_kita/pages/maintenance_history/maintenance_history_page.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_bar_chart.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_period_selector.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_period_sheet.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_recent_history_card.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_summary_grid.dart';
import 'package:flutter_kita/repositories/maintenance/firestore_maintenance_repository.dart';
import 'package:flutter_kita/repositories/maintenance_reporting/firestore_maintenance_reporting_repository.dart';
import 'package:flutter_kita/services/maintenance/maintenance_history_service.dart';
import 'package:flutter_kita/services/maintenance_reporting/maintenance_reporting_service.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_summary_grid_skeleton.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_bar_chart_skeleton.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_recent_history_card_skeleton.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/sheets/info_sheet.dart';
import 'package:flutter_kita/widget/sheets/sheet_helper.dart';

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
  List<MaintenanceHistory> _recentHistory = [];
  bool _isLoading = true;
  late final MaintenanceReportingService _reportingService;
  late final MaintenanceHistoryService _historyService;

  @override
  void initState() {
    super.initState();

    _reportingService = MaintenanceReportingService(
      repository: FirestoreMaintenanceReportingRepository(),
    );
    _historyService = MaintenanceHistoryService(
      FirestoreMaintenanceRepository(),
    );

    _loadReporting();
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

      await _loadReporting();

      return;
    }

    setState(() {
      _selectedPeriod = period;
    });

    await _loadReporting();
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

  Future<void> _loadRecentHistory() async {
    final histories = await _reportingService.getRecentHistory();

    if (!mounted) return;

    setState(() {
      _recentHistory = histories;
    });
  }

  Future<void> _loadReporting() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([_loadSummary(), _loadChart(), _loadRecentHistory()]);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        title: const Text("Laporan Perawatan"),
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: MyColors.black.withValues(alpha: 0.25),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Periode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Row(
                      children: [
                        Text(
                          "${_formatDate(_activeDateRange.start)} - ${_formatDate(_activeDateRange.end)}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(width: 6),

                        const Icon(
                          Icons.calendar_month,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ReportPeriodSelector(
                  selectedPeriod: _selectedPeriod,
                  onChanged: _onPeriodChanged,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              // Summary
              const Text(
                "Ringkasan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              _isLoading
                  ? const ReportSummaryGridSkeleton()
                  : ReportSummaryGrid(summary: _summary),

              const SizedBox(height: 28),

              // Chart
              Row(
                children: [
                  const Text(
                    "Grafik Perawatan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(width: 6),

                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      showAppModalSheet(
                        context: context,
                        builder: (_) => const InfoSheet(
                          title: 'Informasi Grafik',
                          message:
                              'Grafik Perawatan menampilkan jumlah maintenance yang telah diselesaikan pada setiap periode yang dipilih. Data yang ditampilkan hanya berasal dari maintenance yang telah selesai, sehingga maintenance yang berstatus Skipped tidak dihitung.',
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: MyColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _isLoading
                  ? const ReportBarChartSkeleton()
                  : ReportBarChart(data: _chart),

              const SizedBox(height: 24),

              // History
              // History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Perawatan Terakhir",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MaintenanceHistoryPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: MyColors.secondary,
                    ),
                    tooltip: 'Lihat semua',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_isLoading)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, __) =>
                      const ReportRecentHistoryCardSkeleton(),
                )
              else if (_recentHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Belum ada riwayat maintenance.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return ReportRecentHistoryCard(
                      history: _recentHistory[index],
                      service: _historyService,
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
