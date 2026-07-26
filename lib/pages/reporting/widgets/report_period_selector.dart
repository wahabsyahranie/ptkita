import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/report_period.dart';
import 'package:flutter_kita/styles/colors.dart';

class ReportPeriodSelector extends StatelessWidget {
  const ReportPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  final ReportPeriod selectedPeriod;
  final ValueChanged<ReportPeriod> onChanged;

  Widget _buildChip({required String label, required ReportPeriod period}) {
    final selected = selectedPeriod == period;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onChanged(period),

      showCheckmark: false,

      selectedColor: MyColors.secondary,
      backgroundColor: Colors.white,

      side: BorderSide(
        color: selected ? MyColors.secondary : MyColors.greySoft,
      ),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      labelStyle: TextStyle(
        fontSize: 14,
        color: selected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w400,
      ),

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(label: "Minggu", period: ReportPeriod.week),

          const SizedBox(width: 8),

          _buildChip(label: "Bulan", period: ReportPeriod.month),

          const SizedBox(width: 8),

          _buildChip(label: "Tahun", period: ReportPeriod.year),

          const SizedBox(width: 8),

          _buildChip(label: "Custom", period: ReportPeriod.custom),
        ],
      ),
    );
  }
}
