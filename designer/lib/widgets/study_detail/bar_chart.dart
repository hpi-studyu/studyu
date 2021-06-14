import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartView extends StatelessWidget {
  final Map<int, num> data;
  final Color color;

  const BarChartView(this.data, {this.color = Colors.black, Key key}) : super(key: key);

  List<BarChartGroupData> _histogramBarChartData(Color color) => data
      .map((x, y) => MapEntry(
          x,
          BarChartGroupData(
            x: x,
            barRods: [
              BarChartRodData(y: y.toDouble(), colors: [color])
            ],
            showingTooltipIndicators: [0],
          )))
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
            tooltipPadding: const EdgeInsets.all(0),
            tooltipMargin: 8,
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              if (rod.y == 0) return null;
              return BarTooltipItem(
                rod.y.round().toString(),
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        axisTitleData: FlAxisTitleData(
          bottomTitle: AxisTitle(
              titleText: 'Amount of missed days', showTitle: true, textStyle: TextStyle(color: Color(0xff7589a2))),
          leftTitle:
              AxisTitle(titleText: 'Number of participants', showTitle: true, textStyle: TextStyle(color: color)),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) =>
                const TextStyle(color: Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 14),
            margin: 20,
          ),
          leftTitles: SideTitles(showTitles: false),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: _histogramBarChartData(color),
      ),
    );
  }
}
