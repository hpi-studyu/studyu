import 'package:StudyU/screens/study/report/util/linear_regression.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:studyou_core/models/report/sections/report_sections.dart';
import 'package:studyou_core/models/study/studies.dart';

import '../report_section_widget.dart';
import '../util/plot_utilities.dart';

class LinearRegressionSectionWidget extends ReportSectionWidget {
  final LinearRegressionSection section;

  const LinearRegressionSectionWidget(ParseUserStudy instance, this.section) : super(instance);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(aspectRatio: 1.5, child: getDiagram(context)),
      ],
    );
  }

  charts.NumericExtents getExtents(int numberOfPhases, int phaseDuration) =>
      charts.NumericExtents(instance.schedule.includeBaseline ? 0 : 1, 2);

  Widget getDiagram(BuildContext context) {
    final numberOfPhases = instance.interventionOrder.length;
    final phaseDuration = instance.schedule.phaseDuration;
    return charts.NumericComboChart(
      getBarData(),
      animate: true,
      behaviors: [
        charts.SeriesLegend(desiredMaxColumns: 2),
      ],
      domainAxis: charts.NumericAxisSpec(
        viewport: getExtents(numberOfPhases, phaseDuration),
        tickProviderSpec: charts.StaticNumericTickProviderSpec(const []),
      ),
      defaultRenderer: charts.BarRendererConfig<num>(groupingType: charts.BarGroupingType.stacked),
    );
  }

  List<charts.Series<_ResultDatum, num>> getBarData() {
    final colorPalette = PlotUtilities.getInterventionPalette(instance.interventionSet);
    final interventionNames = PlotUtilities.getInterventionNames(instance.interventionSet);
    final interventionOrder = PlotUtilities.getInterventionPositions(instance.interventionSet);
    final values = section.resultProperty.retrieveFromResults(instance);
    final samples = values.entries
        .map((e) => _SampleDatum(instance.getDayOfStudyFor(e.key), e.value, instance.getInterventionForDate(e.key).id))
        .map((e) => MapEntry([
              e.day, //time
              interventionOrder[e.intervention] == 1 ? 1 : 0, //A
              interventionOrder[e.intervention] == 2 ? 1 : 0, //B
            ], e.value));

    final regression = LinearRegression(samples);
    final coefficients = regression.getEstimatedCoefficients();
    final factorA = coefficients.variables[1];
    final factorB = coefficients.variables[2];
    final interventionA = interventionOrder.entries.firstWhere((element) => element.value == 1).key;
    final interventionB = interventionOrder.entries.firstWhere((element) => element.value == 2).key;

    return {
      interventionA: factorA,
      interventionB: factorB,
    }
        .entries
        .map((entry) => charts.Series<_ResultDatum, num>(
              id: entry.key,
              displayName: interventionNames[entry.key],
              seriesColor: colorPalette[entry.key],
              domainFn: (datum, _) => datum.pos,
              measureFn: (datum, _) => datum.value,
              data: [_ResultDatum(interventionOrder[entry.key], entry.value, entry.key)],
            ))
        .toList();
  }
}

class _SampleDatum {
  final num day;
  final num value;
  final String intervention;

  _SampleDatum(this.day, this.value, this.intervention);
}

class _ResultDatum {
  final num pos;
  final num value;
  final String intervention;

  _ResultDatum(this.pos, this.value, this.intervention);
}
