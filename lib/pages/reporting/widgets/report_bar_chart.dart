import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/reporting/maintenance_report_chart.dart';
import 'package:flutter_kita/styles/colors.dart';

class ReportBarChart extends StatelessWidget {
  const ReportBarChart({
    super.key,
    required this.data,
    this.enableHorizontalScroll = false,
  });

  final List<MaintenanceReportChart> data;
  final bool enableHorizontalScroll;

  double _calculateMaxY() {
    if (data.isEmpty) return 5;

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return maxValue == 0 ? 5 : (maxValue + 2).toDouble();
  }

  int _labelInterval() {
    final count = data.length;

    if (count <= 7) {
      return 1;
    }

    if (count <= 14) {
      return 2;
    }

    if (count <= 21) {
      return 3;
    }

    return 5;
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
        color: MyColors.greySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MyColors.greySoft),
      ),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) {
              return const FlLine(
                color: MyColors.background,
                strokeWidth: 0.6,
                dashArray: [6, 4],
              );
            },
          ),

          alignment: BarChartAlignment.spaceAround,

          maxY: _calculateMaxY(),

          barTouchData: BarTouchData(
            enabled: true,

            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              getTooltipColor: (_) => MyColors.white,

              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(
                    color: MyColors.background,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }

                  final interval = _labelInterval();

                  if (index % interval != 0 && index != data.length - 1) {
                    return const SizedBox.shrink();
                  }

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      data[index].label,
                      style: const TextStyle(fontSize: 10),
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
                  width: 20,

                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),

                  color: index.isEven ? MyColors.secondary : MyColors.primary,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
