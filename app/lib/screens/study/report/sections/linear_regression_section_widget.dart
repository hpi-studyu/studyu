import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:studyou_core/models/report/sections/report_sections.dart';
import 'package:studyou_core/models/study/studies.dart';

import '../../../../util/localization.dart';
import '../report_section_widget.dart';
import '../util/linear_regression.dart';
import '../util/plot_utilities.dart';

class LinearRegressionSectionWidget extends ReportSectionWidget {
  final LinearRegressionSection section;

  const LinearRegressionSectionWidget(ParseUserStudy instance, this.section) : super(instance);

  @override
  Widget build(BuildContext context) {
    final interventionOrder = PlotUtilities.getInterventionPositions(instance.interventionSet);
    final values = section.resultProperty.retrieveFromResults(instance);
    final samples = values.entries.map((e) {
      final intervention = instance.getInterventionForDate(e.key).id;
      return MapEntry([
        instance.getDayOfStudyFor(e.key), //time
        interventionOrder[intervention] == 1 ? 1 : 0, //A
        interventionOrder[intervention] == 2 ? 1 : 0, //B
      ], e.value);
    });

    final regression = LinearRegression(samples);
    final coefficients = regression.getEstimatedCoefficients();
    final pValues = regression.getPValues();
    final confidenceIntervals = regression.getConfidenceIntervals(section.alpha);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 1.5, child: _buildDiagram(context, coefficients, confidenceIntervals)),
        _buildResultDescription(context, coefficients, pValues),
      ],
    );
  }

  charts.NumericExtents getExtents(int numberOfPhases, int phaseDuration) =>
      charts.NumericExtents(instance.schedule.includeBaseline ? 0 : 1, 2);

  Widget _buildDiagram(BuildContext context, LinearRegressionResult<num> coefficients,
      LinearRegressionResult<Range<num>> confidenceIntervals) {
    final numberOfPhases = instance.interventionOrder.length;
    final phaseDuration = instance.schedule.phaseDuration;
    return charts.NumericComboChart(
      _getChartData(coefficients, confidenceIntervals),
      animate: true,
      behaviors: [
        charts.SeriesLegend(desiredMaxColumns: 2),
        charts.RangeAnnotation(
            [PlotUtilities.createSeparator(coefficients.intercept, axis: charts.RangeAnnotationAxisType.measure)]),
      ],
      domainAxis: charts.NumericAxisSpec(
        viewport: getExtents(numberOfPhases, phaseDuration),
        tickProviderSpec: charts.StaticNumericTickProviderSpec(const []),
      ),
      defaultRenderer: charts.BarRendererConfig<num>(
        groupingType: charts.BarGroupingType.stacked,
        barRendererDecorator: charts.BarErrorDecorator<num>(),
      ),
    );
  }

  List<charts.Series<_ResultDatum, num>> _getChartData(
      LinearRegressionResult<num> coefficients, LinearRegressionResult<Range<num>> confidenceIntervals) {
    final colorPalette = PlotUtilities.getInterventionPalette(instance.interventionSet);
    final interventionNames = PlotUtilities.getInterventionNames(instance.interventionSet);
    final interventionOrder = PlotUtilities.getInterventionPositions(instance.interventionSet);

    final intercept = coefficients.intercept;
    final factorA = coefficients.variables[1];
    final factorB = coefficients.variables[2];
    final interventionA = PlotUtilities.getInterventionA(instance.interventionSet);
    final interventionB = PlotUtilities.getInterventionB(instance.interventionSet);

    final ciIntercept = confidenceIntervals.intercept;
    final ciA = confidenceIntervals.variables[1];
    final ciB = confidenceIntervals.variables[2];

    return {
      if (instance.schedule.includeBaseline)
        StudyBase.baselineID: _ResultDatum(interventionOrder[StudyBase.baselineID], intercept, ciIntercept),
      interventionA: _ResultDatum(
          interventionOrder[interventionA], intercept + factorA, Range(intercept + ciA.min, intercept + ciA.max)),
      interventionB: _ResultDatum(
          interventionOrder[interventionB], intercept + factorB, Range(intercept + ciB.min, intercept + ciB.max)),
    }
        .entries
        .map((entry) => charts.Series<_ResultDatum, num>(
              id: entry.key,
              displayName: interventionNames[entry.key],
              seriesColor: colorPalette[entry.key],
              domainFn: (datum, _) => datum.pos,
              measureFn: (datum, _) => datum.value,
              measureLowerBoundFn: (datum, _) => datum.confidenceInterval.min,
              measureUpperBoundFn: (datum, _) => datum.confidenceInterval.max,
              data: [entry.value],
            ))
        .toList();
  }

  Widget _buildResultDescription(
      BuildContext context, LinearRegressionResult<num> coefficients, LinearRegressionResult<num> pValues) {
    final interventionNames = PlotUtilities.getInterventionNames(instance.interventionSet);

    var factorA = coefficients.variables[1];
    var factorB = coefficients.variables[2];
    if (section.improvement == ImprovementDirection.negative) {
      factorA = -factorA;
      factorB = -factorB;
    }

    final interventionA = PlotUtilities.getInterventionA(instance.interventionSet);
    final interventionB = PlotUtilities.getInterventionB(instance.interventionSet);

    final pIntercept = pValues.intercept;
    final pA = pValues.variables[1];
    final pB = pValues.variables[2];

    String text;
    //TODO: Talk to a statistics guy about this evaluation logic and model design
    if (pA > section.alpha || pB > section.alpha || pIntercept > section.alpha) {
      text = Nof1Localizations.of(context).translate('report_outcome_inconclusive');
    } else if (instance.schedule.includeBaseline && factorA < 0 && factorB < 0) {
      text = Nof1Localizations.of(context).translate('report_outcome_neither');
    } else if (factorA > factorB) {
      text = Nof1Localizations.of(context)
          .translate('report_outcome_one')
          .replaceAll('{intervention}', interventionNames[interventionA]);
    } else {
      text = Nof1Localizations.of(context)
          .translate('report_outcome_one')
          .replaceAll('{intervention}', interventionNames[interventionB]);
    }

    return Text(text);
  }
}

class _ResultDatum {
  final num pos;
  final num value;
  final Range<num> confidenceInterval;

  _ResultDatum(this.pos, this.value, this.confidenceInterval);
}
