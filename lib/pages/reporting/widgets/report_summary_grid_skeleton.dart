import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/reporting/widgets/report_summary_card_skeleton.dart';

class ReportSummaryGridSkeleton extends StatelessWidget {
  const ReportSummaryGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        ReportSummaryCardSkeleton(),
        ReportSummaryCardSkeleton(),
        ReportSummaryCardSkeleton(),
        ReportSummaryCardSkeleton(),
      ],
    );
  }
}
