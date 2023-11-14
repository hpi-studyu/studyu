import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_core/core.dart';

import '../../../../util/data_processing.dart';
import '../report_section_widget.dart';
import '../util/plot_utilities.dart';

class AverageSectionWidget extends ReportSectionWidget {
  final AverageSection section;

  const AverageSectionWidget(super.subject, this.section, {super.key});

  @override
  Widget build(BuildContext context) {
    final data = getAggregatedData().toList();
    final taskTitle =
        subject.study.observations.firstWhereOrNull((element) => element.id == section.resultProperty!.task)?.title;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (taskTitle != null) Text(taskTitle, style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        getLegend(context, data),
        const SizedBox(height: 8),
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

  Widget getLegend(BuildContext context, List<DiagramDatum> data) {
    final interventionNames = getInterventionNames(context);
    final legends = {
      for (var entry in data)
        interventionNames[entry.intervention]!: Legend(interventionNames[entry.intervention]!, getColor(entry))
    };
    return LegendsListWidget(legends: legends.values.toList());
  }

  Widget getDiagram(BuildContext context, List<DiagramDatum> data) {
    return BarChart(
      getChartData(context, data),
      swapAnimationDuration: const Duration(milliseconds: 150), // Optional
      swapAnimationCurve: Curves.linear, // Optional
    );
  }

  BarChartData getChartData(BuildContext context, List<DiagramDatum> data) {
    final barGroups = getBarGroups(context, data);
    final maxY = ((data.sortedBy((entry) => entry.value).toList().lastOrNull?.value ?? 0) * 1.1).ceilToDouble();
    return BarChartData(
      titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
              axisNameWidget:
                  (section.aggregate != TemporalAggregation.intervention) ? const Text("Phase") : const Text(""),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTitles,
              )),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(
            showTitles: false,
          ))),
      gridData: getGridData(barGroups),
      alignment: BarChartAlignment.spaceAround,
      barGroups: barGroups,
      barTouchData: BarTouchData(enabled: true),
      maxY: maxY,
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: getValues(value),
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
        return Text("${value.toInt() + 1}");
      case TemporalAggregation.intervention:
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  List<BarChartGroupData> getBarGroups(BuildContext context, List<DiagramDatum> data) {
    if (data.isEmpty) return [BarChartGroupData(x: 0)];

    int barCount = 0;
    switch (section.aggregate) {
      case TemporalAggregation.day:
        barCount = subject.study.schedule.length;
      case TemporalAggregation.phase:
        barCount = subject.interventionOrder.length;
      case TemporalAggregation.intervention:
        barCount = subject.selectedInterventionIds.length + (subject.study.schedule.includeBaseline ? 1 : 0);
      default:
    }

    // there is no good way of dynamically setting the width of bars so they
    // fill the chart :( the author of fl_charts themselves recommended using
    // media queries: https://github.com/imaNNeo/fl_chart/issues/370
    // so we take a wild guess and say the bars should fill about half of the
    // space the chart gets which seems to be fine
    final barWidth = MediaQuery.of(context).size.width / 2 / barCount;
    BarChartGroupData barGenerator(int index, {double y = 0, Color? color}) {
      final rod = BarChartRodData(
        toY: y,
        color: color,
        width: barWidth,
        borderRadius: const BorderRadius.all(Radius.circular(1)),
      );
      return BarChartGroupData(x: index, barsSpace: 0, barRods: [rod]);
    }

    var starter = List<BarChartGroupData>.generate(barCount, barGenerator);
    for (var entry in data) {
      starter[entry.x.round()] = barGenerator(entry.x.round(), y: entry.value.toDouble(), color: getColor(entry));
    }
    return starter;
  }

  FlGridData getGridData(List<BarChartGroupData> barGroups) {
    if (section.aggregate != TemporalAggregation.day) {
      return const FlGridData(
        drawHorizontalLine: false,
        drawVerticalLine: false,
      );
    }
    // the grid lines are always at positions in [0, 1] so this is a bit tricky
    // also note that this math is only correct with
    // BarChartAlignment.spaceAround, otherwise it would get even uglier

    // resolution
    final lineCount = barGroups.length * 2;
    bool drawLine(double val) {
      // draw when we are at the border between two phases
      return (val * lineCount % (2 * subject.study.schedule.phaseDuration)).toInt() == 0;
    }

    return FlGridData(
      drawHorizontalLine: false,
      drawVerticalLine: true,
      checkToShowVerticalLine: drawLine,
      verticalInterval: 1 / lineCount,
    );
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
          c = colors[diagram.x.round() - (subject.study.schedule.includeBaseline ? 1 : 0)];
        }
      default:
    }
    return c;
  }

  int getDayIndex(DateTime key) {
    if (subject.study.schedule.includeBaseline) return subject.getDayOfStudyFor(key);
    final schedule = subject.scheduleFor(subject.startedAt!);
    // this always has to be found because studies have to have at least 2
    // interventions
    final offset = schedule.indexWhere((task) => task.id != Study.baselineID);
    return subject.getDayOfStudyFor(key) - offset;
  }

  Iterable<DiagramDatum> getAggregatedData() {
    final values = section.resultProperty!.retrieveFromResults(subject);
    final data = values.entries.map(
      (e) => DiagramDatum(
        getDayIndex(e.key),
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
    final names = {for (var intervention in subject.study.interventions) intervention.id: intervention.name};
    names[Study.baselineID] = AppLocalizations.of(context)!.baseline;
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
