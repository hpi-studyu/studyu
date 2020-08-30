import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:studyou_core/models/interventions/intervention_set.dart';
import 'package:studyou_core/models/study/study.dart';

class PlotUtilities {
  static Map<String, charts.Color> getInterventionPalette(InterventionSet interventionSet) {
    final interventions = [...interventionSet.interventions];
    final colors = <String, charts.Color>{};
    if (interventions.any((intervention) => intervention.id == StudyBase.baselineID)) {
      colors[StudyBase.baselineID] = charts.MaterialPalette.gray.shadeDefault;
      interventions.removeWhere((intervention) => intervention.id == StudyBase.baselineID);
    }
    colors[interventions.first.id] = charts.MaterialPalette.blue.shadeDefault;
    colors[interventions.last.id] = charts.MaterialPalette.deepOrange.shadeDefault;
    return colors;
  }

  static Map<String, int> getInterventionPositions(InterventionSet interventionSet) {
    final interventions = [...interventionSet.interventions];
    final order = <String, int>{};
    if (interventions.any((intervention) => intervention.id == StudyBase.baselineID)) {
      order[StudyBase.baselineID] = 0;
      interventions.removeWhere((intervention) => intervention.id == StudyBase.baselineID);
    }
    order[interventions.first.id] = 1;
    order[interventions.last.id] = 2;
    return order;
  }

  static String getInterventionA(InterventionSet interventionSet) {
    final interventions = [
      ...interventionSet.interventions.where((intervention) => intervention.id != StudyBase.baselineID)
    ];
    return interventions[0].id;
  }

  static String getInterventionB(InterventionSet interventionSet) {
    final interventions = [
      ...interventionSet.interventions.where((intervention) => intervention.id != StudyBase.baselineID)
    ];
    return interventions[1].id;
  }

  static Map<String, String> getInterventionNames(InterventionSet interventionSet) =>
      {for (var intervention in interventionSet.interventions) intervention.id: intervention.name};

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
