import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

import '../../../../util/data_processing.dart';
import '../report_section_widget.dart';
import '../util/plot_utilities.dart';

class AverageSectionWidget extends ReportSectionWidget {
  final AverageSection section;

  const AverageSectionWidget(StudySubject subject, this.section, {Key? key}) : super(subject, key: key);

  @override
  Widget build(BuildContext context) {
    final data = getAggregatedData().toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(aspectRatio: 1.5, child: getDiagram(context, data)),
      ],
    );
  }

  List<int> get titlePos {
    final numberOfPhases = subject.interventionOrder.length;
    final phaseDuration = subject.study.schedule.phaseDuration;
    return Iterable<int>.generate(numberOfPhases)
        .map((i) => (((i + 1) * phaseDuration - ((phaseDuration / 2) - 1)) - 1).floor())
        .toList();
  }

  List<int> get phasePos {
    final numberOfPhases = subject.interventionOrder.length;
    final phaseDuration = subject.study.schedule.phaseDuration;
    return Iterable<int>.generate(numberOfPhases).map((i) => (i + 1) * phaseDuration).toList();
  }

  //bool get needsSeparators => section.aggregate == TemporalAggregation.day;
  //bool get needsDomainLabel => section.aggregate != TemporalAggregation.intervention;

  Widget getDiagram(BuildContext context, List<DiagramDatum> data) {
    return BarChart(
      getChartData(data),
      swapAnimationDuration: const Duration(milliseconds: 150), // Optional
      swapAnimationCurve: Curves.linear, // Optional
    );

    /*return charts.NumericComboChart(
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
    );*/
  }

  /*charts.RangeAnnotation<num> generateSeperators(int numberOfPhases, int phaseDuration) => charts.RangeAnnotation<num>(
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

  Iterable<DiagramDatum> getAggregatedData() {
    final values = section.resultProperty.retrieveFromResults(subject);
    final data = values.entries.map(
      (e) => DiagramDatum(
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
            (data, day) => DiagramDatum(
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
            (data, phase) => DiagramDatum(
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
            (data, intervention) => DiagramDatum(
              order[intervention],
              foldAggregateMean()(data.map((e) => e.value)),
              null,
              intervention,
            ),
          )
          .map((e) => e.value);
    }
  }

  List<charts.Series<DiagramDatum, num>> getBarData() {
    final colorPalette = getInterventionPalette(subject.selectedInterventions);
    final interventionNames = getInterventionNames(subject.selectedInterventions);

    return getAggregatedData()
        .groupBy((datum) => datum.intervention)
        .map(
          (entry) => charts.Series<DiagramDatum, num>(
            id: entry.key,
            displayName: interventionNames[entry.key],
            seriesColor: colorPalette[entry.key],
            domainFn: (datum, _) => datum.x,
            measureFn: (datum, _) => datum.value,
            data: entry.value.toList(),
          ),
        )
        .toList();
  }*/

  BarChartData getChartData(List<DiagramDatum> data) {
    //final colorPalette = getInterventionPalette(subject.selectedInterventions);
    //final interventionNames = getInterventionNames(subject.selectedInterventions);
/*
    final task = subject.study.observations.firstWhere((element) =>
    element.id == section.resultProperty!.task).
        .firstWhere((element) => element.id == section.resultProperty!.property);
    print(task.toString());
*/
    return BarChartData(
      //minX: 1,
      //maxX: subject.study.schedule.length.toDouble(),
      titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
              axisNameWidget:
                  (section.aggregate != TemporalAggregation.intervention) ? const Text("Phase") : const Text(""),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTitles,
              )),
          // ignore: prefer_const_constructors
          topTitles: AxisTitles(
              // ignore: prefer_const_constructors
              sideTitles: SideTitles(
            showTitles: false,
          ))),
      // ignore: prefer_const_constructors
      gridData: FlGridData(
        drawHorizontalLine: false,
        drawVerticalLine: false,
        /*checkToShowVerticalLine: (val) => true,
        getDrawingVerticalLine: (val) => FlLine(color: Colors.black),
        verticalInterval: subject.study.schedule.phaseDuration.toDouble(),*/
      ),
      barGroups: getBarGroups(data),
      barTouchData: BarTouchData(
        enabled: false, // todo enable with x and y value
      ),
      //maxY: ; // todo get min and max values of question
      // todo add question title to top of diagram (e.g. "pain rating")
      // todo add legend
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: getValues(value),
      //space: 4,
    );
  }

  Widget getValues(double value) {
    switch (section.aggregate) {
      case TemporalAggregation.day:
        final index = titlePos.indexOf(value.round());
        if (index != -1) {
          return Text("${index + 1}");
        } else {
          return const SizedBox.shrink();
        }
      case TemporalAggregation.phase:
        return Text("${value + 1}");
      case TemporalAggregation.intervention:
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  List<BarChartGroupData> getBarGroups(List<DiagramDatum> data) {
    // groupBy((datum) => datum.intervention)
    //data.add(DiagramDatum(1, 10, DateTime.now(), subject.selectedInterventions.first.id));
    //data.add(DiagramDatum(100, 3, DateTime.now(), subject.selectedInterventions.first.id));
    if (data.isEmpty) return [BarChartGroupData(x: 0)];
    //data.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
    //final numberOfPhases = subject.interventionOrder.length;
    //final phaseDuration = subject.study.schedule.phaseDuration;
    List<BarChartGroupData> starter = List.empty();
    switch (section.aggregate) {
      case TemporalAggregation.day:
        starter = List<BarChartGroupData>.generate(
            subject.study.schedule.length,
            (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: 0,
                    )
                  ],
                ));
      case TemporalAggregation.phase:
        starter = List<BarChartGroupData>.generate(
            subject.interventionOrder.length,
            (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: 0,
                    )
                  ],
                ));
      case TemporalAggregation.intervention:
        int interventionCount =
            subject.selectedInterventionIds.length + (subject.study.schedule.includeBaseline ? 1 : 0);
        starter = List<BarChartGroupData>.generate(
            interventionCount,
            (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: 0,
                    )
                  ],
                ));
      default:
    }
    for (var entry in data) {
      starter[entry.x.round()] = BarChartGroupData(x: entry.x.round(), barRods: [
        BarChartRodData(
          toY: entry.value.toDouble(),
          color: getColor(entry),
        )
      ]);
    }
    return starter;

    /*return data.mapIndexed((idx, entry) {
      //print(idx);
      //if (idx < data.length) {
      return BarChartGroupData(x: entry.x.round(), barRods: [
        charts.BarChartRodData(
          toY: entry.value.toDouble(),
          color: getColor(entry, subject),
        )
      ]);
      //}
      /*return BarChartGroupData(
        x: idx+1,
        barRods: [
          charts.BarChartRodData(
            toY: 5,
            /*color: getColor(DiagramDatum(idx+1, 5, null, subject.selectedInterventions[0].id), subject),*/
          )
        ]
      );*/
    }).toList();*/
    /*return List<BarChartGroupData>.generate(subject.study.schedule.length, (index) =>  BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            toY: Random().nextInt(11).toDouble(),
            color: getColor(index),
          )
        ],
      ));*/
  }

  MaterialColor getColor(DiagramDatum diagram) {
    const baselineColor = Colors.grey;
    final colors = [Colors.blue, Colors.orange];
    MaterialColor? c = Colors.teal;

    switch (section.aggregate) {
      case TemporalAggregation.day:
        //c = colors[subject.interventionOrder.indexOf(diagram.intervention)];
        if (subject.study.schedule.includeBaseline && diagram.x < subject.study.schedule.phaseDuration) {
          // if id == "_baseline"
          c = baselineColor;
        } else {
          c = colors[subject.selectedInterventions.map((e) => e.id).toList().indexOf(diagram.intervention)];
        }
      case TemporalAggregation.phase:
        if (subject.study.schedule.includeBaseline && diagram.x == 0) {
          c = baselineColor;
        } else {
          c = colors[subject.selectedInterventions.map((e) => e.id).toList().indexOf(diagram.intervention)];
        }
      case TemporalAggregation.intervention:
        if (subject.study.schedule.includeBaseline && diagram.x == 0) {
          c = baselineColor;
        } else {
          c = colors[diagram.x.round() - 1];
        }
      default:
    }
    /*phasePos.forEachIndexed((index, phaseBreak) {
      if (includeBaseline && pos <= phasePos[0]) {
        c = Colors.grey;
      }
      if (pos <= phaseBreak && c == null) {
        c = colors[(index % colors.length)];
      }
    });*/
    return c; //?? Colors.green;
  }

  Iterable<DiagramDatum> getAggregatedData() {
    final values = section.resultProperty!.retrieveFromResults(subject);
    final data = values.entries.map(
      (e) => DiagramDatum(
        subject.getDayOfStudyFor(e.key),
        e.value,
        e.key,
        subject.getInterventionForDate(e.key)!.id,
      ),
    );

    if (section.aggregate == TemporalAggregation.day) {
      return data
          .groupBy((e) => e.x)
          .aggregateWithKey(
            (data, day) => DiagramDatum(
              day,
              foldAggregateMean()(data.map((e) => e.value)),
              null,
              data.first.intervention,
            ),
          )
          .map((e) => e.value);
    } else if (section.aggregate == TemporalAggregation.phase) {
      return data
          .groupBy((e) => subject.getInterventionIndexForDate(e.timestamp!))
          .aggregateWithKey(
            (data, phase) => DiagramDatum(
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
            (data, intervention) => DiagramDatum(
              order[intervention] as num,
              foldAggregateMean()(data.map((e) => e.value)),
              null,
              intervention,
            ),
          )
          .map((e) => e.value);
    }
  }

  Map<String, String?> getInterventionNames(BuildContext context) {
    final names = { for (var intervention in subject.study.interventions) intervention.id: intervention.name };
    names['__baseline'] = AppLocalizations.of(context)!.baseline;
    return names;
  }
}

class DiagramDatum {
  final num x;
  final num value;
  final DateTime? timestamp;
  final String intervention;

  DiagramDatum(this.x, this.value, this.timestamp, this.intervention);
}
