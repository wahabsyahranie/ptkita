import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_chart.dart';
import 'package:flutter_kita/styles/colors.dart';

class ReportBarChart extends StatelessWidget {
  const ReportBarChart({super.key, required this.data});

  final List<MaintenanceReportChart> data;

  double _calculateMaxY() {
    if (data.isEmpty) return 5;

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return maxValue == 0 ? 5 : (maxValue + 2).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: MyColors.greySoft),
        ),
        child: const Text(
          'Belum ada data',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MyColors.greySoft),
      ),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),

          alignment: BarChartAlignment.spaceAround,

          maxY: _calculateMaxY(),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index].label,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups: List.generate(data.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data[index].value.toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  color: MyColors.secondary,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
