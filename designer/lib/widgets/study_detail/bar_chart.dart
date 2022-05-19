import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartView extends StatelessWidget {
  final Map<int, num> data;
  final Color color;

  const BarChartView(this.data, {this.color = Colors.black, Key key}) : super(key: key);

  List<BarChartGroupData> _histogramBarChartData(Color color) => data
      .map(
        (x, y) => MapEntry(
          x,
          BarChartGroupData(
            x: x,
            barRods: [BarChartRodData(toY: y.toDouble(), color: color)],
            showingTooltipIndicators: [0],
          ),
        ),
      )
      .values
      .toList();

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        // maxY: 20,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 8,
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              if (rod.toY == 0) return null;
              return BarTooltipItem(
                rod.toY.round().toString(),
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              'Amount of missed days',
              style: TextStyle(
                color: Color(0xff7589a2),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, titleMeta) {
                return const Padding(
                  // You can use any widget here
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              'Number of participants',
              style: TextStyle(
                color: color,
              ),
            ),
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: _histogramBarChartData(color),
      ),
    );
  }
}
