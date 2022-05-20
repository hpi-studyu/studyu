import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartView extends StatelessWidget {
  final Map<int, num> data;
  final Color color;

  const BarChartView(this.data, {this.color = Colors.black, Key key})
      : super(key: key);

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
        //maxY: data.values.max.toDouble() + data.values.max.toDouble() * 0.25,
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
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              'Amount of missed days',
              style: TextStyle(
                color: Color(0xff7589a2),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              // TODO: `interval` is currently bugged:
              // see: https://github.com/imaNNeoFighT/fl_chart/issues/964
              //interval: 5,
              reservedSize: 50,
              getTitlesWidget: (value, titleMeta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      color: Color(0xff7589a2),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              'Number of participants',
              style: TextStyle(color: color),
            ),
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, titleMeta) {
                return Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    value.toString(),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
        ),
        borderData: FlBorderData(show: false),
        barGroups: _histogramBarChartData(color),
      ),
    );
  }
}
