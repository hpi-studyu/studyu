import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:studyou_core/models/report/sections/report_sections.dart';
import 'package:studyou_core/models/study/studies.dart';

import '../../../../util/data_processing.dart';
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

  Iterable<_DiagramDatum> getAggregatedData() {
    final values = section.resultProperty.retrieveFromResults(instance);
    final data = values.entries.map((e) => _DiagramDatum(
          instance.getDayOfStudyFor(e.key),
          e.value,
          e.key,
          instance.getInterventionForDate(e.key).id,
        ));

    final order = PlotUtilities.getInterventionPositions(instance.interventionSet);
    return data
        .groupBy((e) => e.intervention)
        .aggregateWithKey((data, intervention) => _DiagramDatum(
              order[intervention],
              FoldAggregators.mean()(data.map((e) => e.value)),
              null,
              intervention,
            ))
        .map((e) => e.value);
  }

  List<charts.Series<_DiagramDatum, num>> getBarData() {
    final colorPalette = PlotUtilities.getInterventionPalette(instance.interventionSet);
    final interventionNames = PlotUtilities.getInterventionNames(instance.interventionSet);

    return getAggregatedData()
        .groupBy((datum) => datum.intervention)
        .map((entry) => charts.Series<_DiagramDatum, num>(
              id: entry.key,
              displayName: interventionNames[entry.key],
              seriesColor: colorPalette[entry.key],
              domainFn: (datum, _) => datum.x,
              measureFn: (datum, _) => datum.value,
              data: entry.value.toList(),
            ))
        .toList();
  }
}

class _DiagramDatum {
  final num x;
  final num value;
  final DateTime timestamp;
  final String intervention;

  _DiagramDatum(this.x, this.value, this.timestamp, this.intervention);
}
