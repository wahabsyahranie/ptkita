import 'package:flutter/material.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_summary.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_summary_card.dart';

class ReportSummaryGrid extends StatelessWidget {
  const ReportSummaryGrid({super.key, required this.summary});

  final MaintenanceReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Total',
                value: summary.total.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportSummaryCard(
                title: 'Selesai',
                value: summary.completed.toString(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Dilewati',
                value: summary.skipped.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportSummaryCard(
                title: 'Quantity',
                value: summary.quantity.toString(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
