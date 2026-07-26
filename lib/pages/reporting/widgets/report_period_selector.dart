import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/report_period.dart';

class ReportPeriodSelector extends StatelessWidget {
  const ReportPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  final ReportPeriod selectedPeriod;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text("Minggu"),
            selected: selectedPeriod == ReportPeriod.week,
            onSelected: (_) => onChanged(ReportPeriod.week),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Bulan"),
            selected: selectedPeriod == ReportPeriod.month,
            onSelected: (_) => onChanged(ReportPeriod.month),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Tahun"),
            selected: selectedPeriod == ReportPeriod.year,
            onSelected: (_) => onChanged(ReportPeriod.year),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Custom"),
            selected: selectedPeriod == ReportPeriod.custom,
            onSelected: (_) => onChanged(ReportPeriod.custom),
          ),
        ],
      ),
    );
  }
}
