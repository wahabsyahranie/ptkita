import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/repair/weekly_repair_chart_model.dart';
import '../../../styles/colors.dart';

class RepairChartCard extends StatelessWidget {
  final Future<WeeklyRepairChartModel> future;
  final String chartMode;
  final ValueChanged<String> onModeChanged;

  const RepairChartCard({
    super.key,
    required this.future,
    required this.chartMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyColors.greySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),
          _legend(),
          const SizedBox(height: 16),
          FutureBuilder<WeeklyRepairChartModel>(
            future: future,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final model = snap.data!;
              return _buildChart(model);
            },
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Grafik Perbaikan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: chartMode,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
            DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
          ],
          onChanged: (value) {
            if (value != null) onModeChanged(value);
          },
        ),
      ],
    );
  }

  Widget _legend() {
    return const Row(
      children: [
        _LegendDot(color: MyColors.secondary, text: "Garansi"),
        SizedBox(width: 16),
        _LegendDot(color: MyColors.info, text: "Non Garansi"),
        SizedBox(width: 16),
        _LegendDot(color: MyColors.success, text: "Total"),
      ],
    );
  }

  Widget _buildChart(WeeklyRepairChartModel model) {
    final maxY = _calculateMaxY([
      model.warranty,
      model.nonWarranty,
      model.total,
    ]);

    final interval = (maxY / 5).ceilToDouble();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const titles = ['M1', 'M2', 'M3', 'M4'];
                  if (value.toInt() >= 0 && value.toInt() < titles.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        titles[value.toInt()],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            _line(model.warranty, MyColors.secondary),
            _line(model.nonWarranty, MyColors.info),
            _line(model.total, MyColors.success),
          ],
        ),
      ),
    );
  }

  LineChartBarData _line(List<int> values, Color color) {
    return LineChartBarData(
      spots: List.generate(
        values.length,
        (i) => FlSpot(i.toDouble(), values[i].toDouble()),
      ),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: true),
    );
  }

  double _calculateMaxY(List<List<int>> allData) {
    int maxValue = 0;

    for (var list in allData) {
      for (var value in list) {
        if (value > maxValue) {
          maxValue = value;
        }
      }
    }

    if (maxValue == 0) return 5;
    final magnitude = (maxValue / 5).ceil();
    return (magnitude * 5).toDouble();
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
