import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/repair/repair_chart_model.dart';
import '../../../styles/colors.dart';

/// ===============================================================
/// RepairChartCard
/// Widget utama untuk menampilkan grafik perbaikan
/// ===============================================================
class RepairChartCard extends StatelessWidget {
  final Future<RepairChartModel> future;
  final String chartMode; // weekly / monthly / quarterly
  final ValueChanged<String> onModeChanged;

  const RepairChartCard({
    super.key,
    required this.future,
    required this.chartMode,
    required this.onModeChanged,
  });

  /// ---------------------------------------------------------------
  /// Build utama card
  /// ---------------------------------------------------------------
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
          _buildHeader(),
          const SizedBox(height: 20),

          /// Legend tinggi tetap supaya layout stabil
          const SizedBox(height: 24, child: _LegendRow()),

          const SizedBox(height: 16),

          /// Chart tinggi tetap supaya tidak berubah saat rebuild
          SizedBox(
            height: 260, // 🔥 lebih proporsional dari 220
            child: FutureBuilder<RepairChartModel>(
              future: future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _buildChart(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------------------------------------------------------
  /// Header + Dropdown
  /// ---------------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Grafik Perbaikan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: chartMode,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: "weekly", child: Text("Mingguan")),
            DropdownMenuItem(value: "monthly", child: Text("Bulanan")),
            DropdownMenuItem(value: "quarterly", child: Text("Kuartalan")),
          ],
          onChanged: (value) {
            if (value != null) onModeChanged(value);
          },
        ),
      ],
    );
  }

  /// ---------------------------------------------------------------
  /// Build Chart berdasarkan mode
  /// ---------------------------------------------------------------
  Widget _buildChart(RepairChartModel model) {
    const double maxY = 10; // 🔥 Fixed scale konsisten
    const double interval = 2;

    if (chartMode == "monthly") {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: model.total.length * 90.0, // 🔥 dinamis sesuai jumlah bulan
          child: _buildLineChart(model, maxY, interval),
        ),
      );
    }

    return _buildLineChart(model, maxY, interval);
  }

  /// ---------------------------------------------------------------
  /// LineChart utama
  /// ---------------------------------------------------------------
  Widget _buildLineChart(RepairChartModel model, double maxY, double interval) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (model.total.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,

        gridData: FlGridData(
          show: true,
          horizontalInterval: interval, // 🔥 sinkron dengan Y-axis
        ),

        borderData: FlBorderData(show: false),

        lineTouchData: const LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
          ),
        ),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          /// Bottom titles (M1 / Jan / Q1)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                final titles = _getTitles();

                if (index >= 0 && index < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      titles[index],
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          /// Left titles (0,2,4,6,8,10)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 40,
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
    );
  }

  /// ---------------------------------------------------------------
  /// Label sesuai mode
  /// ---------------------------------------------------------------
  List<String> _getTitles() {
    if (chartMode == 'weekly') {
      return ['M1', 'M2', 'M3', 'M4'];
    }

    if (chartMode == 'monthly') {
      return [
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
    }

    return ['Q1', 'Q2', 'Q3', 'Q4'];
  }

  /// ---------------------------------------------------------------
  /// Builder line per kategori
  /// ---------------------------------------------------------------
  LineChartBarData _line(List<int> values, Color color) {
    return LineChartBarData(
      spots: List.generate(
        values.length,
        (i) => FlSpot(i.toDouble(), values[i].toDouble()),
      ),
      isCurved: true,
      curveSmoothness: 0.1,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: true),
    );
  }
}

/// ===============================================================
/// Legend Row
/// ===============================================================
class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
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
}

/// ===============================================================
/// Legend Dot
/// ===============================================================
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
