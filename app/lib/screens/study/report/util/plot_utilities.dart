import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

class PlotUtilities {
  static Map<String, charts.Color> getInterventionPalette(List<Intervention> interventions) {
    final colors = <String, charts.Color>{};
    if (interventions.any((intervention) => intervention.id == Study.baselineID)) {
      colors[Study.baselineID] = charts.MaterialPalette.gray.shadeDefault;
      interventions.removeWhere((intervention) => intervention.id == Study.baselineID);
    }
    colors[interventions.first.id] = charts.MaterialPalette.blue.shadeDefault;
    colors[interventions.last.id] = charts.MaterialPalette.deepOrange.shadeDefault;
    return colors;
  }

  static Map<String, int> getInterventionPositions(List<Intervention> interventions) {
    final order = <String, int>{};
    if (interventions.any((intervention) => intervention.id == Study.baselineID)) {
      order[Study.baselineID] = 0;
      interventions.removeWhere((intervention) => intervention.id == Study.baselineID);
    }
    order[interventions.first.id] = 1;
    order[interventions.last.id] = 2;
    return order;
  }

  static List<Intervention> getInterventionsWithoutBaseline(List<Intervention> interventions) =>
      interventions.where((intervention) => intervention.id != Study.baselineID).toList();

  static String getInterventionA(List<Intervention> interventions) =>
      getInterventionsWithoutBaseline(interventions)[0].id;

  static String getInterventionB(List<Intervention> interventions) =>
      getInterventionsWithoutBaseline(interventions)[1].id;

  static Map<String, String> getInterventionNames(List<Intervention> interventions) =>
      {for (var intervention in interventions) intervention.id: intervention.name};

  static charts.LineAnnotationSegment<T> createSeparator<T>(T value,
          {charts.RangeAnnotationAxisType axis = charts.RangeAnnotationAxisType.domain}) =>
      charts.LineAnnotationSegment<T>(
        value,
        axis,
        color: charts.MaterialPalette.gray.shade400,
        strokeWidthPx: 1,
      );

  static charts.StaticNumericTickProviderSpec createNumericTicks(Iterable<MapEntry<num, String>> ticks,
          {charts.TextStyleSpec style}) =>
      charts.StaticNumericTickProviderSpec(
        ticks.map((entry) => charts.TickSpec<num>(entry.key, label: entry.value, style: style)).toList(),
      );

  static charts.TextStyleSpec convertTextTheme(TextStyle style) => charts.TextStyleSpec(
        fontFamily: style.fontFamily,
        fontSize: style.fontSize.toInt(),
        lineHeight: style.height,
        color: charts.Color(r: style.color.red, g: style.color.green, b: style.color.blue, a: style.color.alpha),
      );
}
