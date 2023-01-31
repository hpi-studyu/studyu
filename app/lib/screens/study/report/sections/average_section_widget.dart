import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import '../../../../util/data_processing.dart';
import '../report_section_widget.dart';
import '../util/plot_utilities.dart';

class AverageSectionWidget extends ReportSectionWidget {
  final AverageSection section;

  const AverageSectionWidget(StudySubject subject, this.section) : super(subject);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(aspectRatio: 1.5, child: getDiagram(context)),
      ],
    );
  }

  bool get needsSeparators => section.aggregate == TemporalAggregation.day;
  bool get needsDomainLabel => section.aggregate != TemporalAggregation.intervention;

  charts.RangeAnnotation<num> generateSeperators(int numberOfPhases, int phaseDuration) => charts.RangeAnnotation<num>(
        Iterable<int>.generate(numberOfPhases + 1).map((i) => createPlotSeparator(i * phaseDuration - 0.5)).toList(),
      );

  charts.StaticNumericTickProviderSpec generateTicks(int numberOfPhases, int phaseDuration) {
    if (section.aggregate == TemporalAggregation.intervention) {
      return const charts.StaticNumericTickProviderSpec([]);
    } else if (section.aggregate == TemporalAggregation.phase) {
      return createNumericTicks(
        Iterable<int>.generate(numberOfPhases).map((i) => MapEntry(i, (i + 1).toString())),
      );
    } else {
      return createNumericTicks(
        Iterable<int>.generate(numberOfPhases)
            .map((i) => MapEntry(i * phaseDuration + (phaseDuration - 1) / 2, (i + 1).toString())),
      );
    }
  }

  charts.NumericExtents getExtents(int numberOfPhases, int phaseDuration) {
    if (section.aggregate == TemporalAggregation.intervention) {
      return charts.NumericExtents(subject.study.schedule.includeBaseline ? 0 : 1, 2);
    } else if (section.aggregate == TemporalAggregation.phase) {
      return charts.NumericExtents(0, numberOfPhases - 1);
    } else {
      return charts.NumericExtents(0, (numberOfPhases * phaseDuration) - 1);
    }
  }

  Widget getDiagram(BuildContext context) {
    final numberOfPhases = subject.interventionOrder.length;
    final phaseDuration = subject.study.schedule.phaseDuration;
    return charts.NumericComboChart(
      getBarData(),
      animate: true,
      behaviors: [
        charts.SeriesLegend(desiredMaxColumns: 2),
        if (needsSeparators) generateSeperators(numberOfPhases, phaseDuration),
        if (needsDomainLabel)
          charts.ChartTitle(
            AppLocalizations.of(context).report_axis_phase,
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleStyleSpec: convertTextTheme(Theme.of(context).textTheme.bodySmall),
          )
      ],
      domainAxis: charts.NumericAxisSpec(
        viewport: getExtents(numberOfPhases, phaseDuration),
        tickProviderSpec: generateTicks(numberOfPhases, phaseDuration),
      ),
      defaultRenderer: charts.BarRendererConfig<num>(groupingType: charts.BarGroupingType.stacked),
    );
  }

  Iterable<_DiagramDatum> getAggregatedData() {
    final values = section.resultProperty.retrieveFromResults(subject);
    final data = values.entries.map(
      (e) => _DiagramDatum(
        subject.getDayOfStudyFor(e.key),
        e.value,
        e.key,
        subject.getInterventionForDate(e.key).id,
      ),
    );

    if (section.aggregate == TemporalAggregation.day) {
      return data
          .groupBy((e) => e.x)
          .aggregateWithKey(
            (data, day) => _DiagramDatum(
              day,
              foldAggregateMean()(data.map((e) => e.value)),
              null,
              data.first.intervention,
            ),
          )
          .map((e) => e.value);
    } else if (section.aggregate == TemporalAggregation.phase) {
      return data
          .groupBy((e) => subject.getInterventionIndexForDate(e.timestamp))
          .aggregateWithKey(
            (data, phase) => _DiagramDatum(
              phase,
              foldAggregateMean()(data.map((e) => e.value)),
              null,
              data.first.intervention,
            ),
          )
          .map((e) => e.value);
    } else {
      final order = getInterventionPositions(subject.selectedInterventions);
      return data
          .groupBy((e) => e.intervention)
          .aggregateWithKey(
            (data, intervention) => _DiagramDatum(
              order[intervention],
              foldAggregateMean()(data.map((e) => e.value)),
              null,
              intervention,
            ),
          )
          .map((e) => e.value);
    }
  }

  List<charts.Series<_DiagramDatum, num>> getBarData() {
    final colorPalette = getInterventionPalette(subject.selectedInterventions);
    final interventionNames = getInterventionNames(subject.selectedInterventions);

    return getAggregatedData()
        .groupBy((datum) => datum.intervention)
        .map(
          (entry) => charts.Series<_DiagramDatum, num>(
            id: entry.key,
            displayName: interventionNames[entry.key],
            seriesColor: colorPalette[entry.key],
            domainFn: (datum, _) => datum.x,
            measureFn: (datum, _) => datum.value,
            data: entry.value.toList(),
          ),
        )
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
