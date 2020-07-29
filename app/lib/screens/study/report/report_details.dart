import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:normal/normal.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:stats/stats.dart';
import 'package:studyou_core/models/models.dart';

import '../../../routes.dart';
import '../../../util/localization.dart';
import 'performance_details.dart';

class ReportDetailsScreen extends StatelessWidget {
  final StudyInstance reportStudy;

  static MaterialPageRoute routeFor({@required StudyInstance reportStudy}) => MaterialPageRoute(
      builder: (_) => ReportDetailsScreen(reportStudy), settings: RouteSettings(name: Routes.reportDetails));

  const ReportDetailsScreen(this.reportStudy, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final outcome = reportStudy.reportSpecification != null
        ? reportStudy.reportSpecification.outcomes.isNotEmpty ? reportStudy.reportSpecification.outcomes[0] : null
        : null;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(MdiIcons.download),
            // TODO add pdf download
            onPressed: () => null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReportModule(ReportGeneralDetailsModule(reportStudy)),
            ReportModule(
              ReportPerformanceModule(reportStudy),
              onTap: () => Navigator.push(context, PerformanceDetailsScreen.routeFor(reportStudy: reportStudy)),
            ),
            if (outcome != null)
              ReportModule(
                  ReportOutcomeModule(reportStudy, reportStudy.reportSpecification.outcomes[0], primary: true)),
          ],
        ),
      ),
    );
  }
}

class ReportModule extends StatelessWidget {
  final ReportModuleContent module;
  final Function onTap;

  const ReportModule(this.module, {this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: module,
          ),
        ),
      );
}

abstract class ReportModuleContent extends StatelessWidget {
  final StudyInstance instance;

  const ReportModuleContent(this.instance);
}

class ReportGeneralDetailsModule extends ReportModuleContent {
  const ReportGeneralDetailsModule(StudyInstance instance) : super(instance);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(instance.description),
        ],
      );
}

class ReportPerformanceModule extends ReportModuleContent {
  const ReportPerformanceModule(StudyInstance instance) : super(instance);

  // TODO move to model
  final minimum = 0.2;

  @override
  Widget build(BuildContext context) {
    final powerLevel = getPowerLevel();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
              '${Nof1Localizations.of(context).translate('current_power_level')}: ${getPowerLevelDescription(powerLevel)}'),
        ),
        PerformanceBar(
          progress: powerLevel,
          minimum: minimum,
        ),
      ],
    );
  }

    String getPowerLevelDescription(double powerLevel) {
      // TODO add useful power level wording
      if (powerLevel == 0) {
        return 'Not enough data.';
      } else if (powerLevel < minimum) {
        return 'Too low';
      } else if (powerLevel < 0.9) {
        return 'High enough';
      } else {
      return 'OVER 9000';
      }
    }

    double getPowerLevel() {
      if (instance.reportSpecification?.outcomes == null || instance.reportSpecification.outcomes.isEmpty) {
        print('Outcomes missing.');
      }
      final primaryOutcome = instance.reportSpecification.outcomes[0];
      final results = <List<num>>[];
      instance.getResultsByInterventionId(taskId: primaryOutcome.taskId).forEach((key, value) {
        final data = value
            .whereType<Result<QuestionnaireState>>()
            .map((result) => result.result.answers[primaryOutcome.questionId].response)
            .whereType<num>()
            .toList();
        if (data.isNotEmpty && key != '__baseline') results.add(data);
      });

      if (results.length != 2 || results[0].isEmpty || results[1].isEmpty) {
        print('The given values are incorrect!');
        return 0;
      }

      final mean0 = Stats.fromData(results[0]).average;
      final mean1 = Stats.fromData(results[1]).average;
      final sD = Stats.fromData([...results[0], ...results[1]]).standardDeviation;

      // TODO might be cdf
      return Normal.pdf(-1.96 + ((mean0 - mean1) / sqrt(pow(sD, 2) / (results[0].length + results[1].length)))) +
          Normal.pdf(-1.96 - ((mean0 - mean1) / sqrt(pow(sD, 2) / (results[0].length + results[1].length))));
    }
}

class PerformanceBar extends StatelessWidget {
  final double progress;
  final double minimum;

  const PerformanceBar({@required this.progress, this.minimum, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rainbow = Rainbow(spectrum: [Colors.red, Colors.yellow, Colors.green], rangeStart: 0, rangeEnd: 1);
    final fullSpectrum = List<double>.generate(3, (index) => index * 0.5)
        .map<Color>((index) => rainbow[index].withOpacity(0.4))
        .toList();
    final colorSamples =
        List<double>.generate(11, (index) => index * 0.1 * progress).map<Color>((index) => rainbow[index]).toList();

    final spacing = (minimum * 1000).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: fullSpectrum,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: colorSamples,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      color: Colors.grey[600],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        if (minimum != null && minimum >= 0 && minimum <= 1)
          Column(
            children: [
              Row(
                children: [
                  if (spacing > 0)
                    Spacer(
                      flex: spacing,
                    ),
                  Container(
                    width: 2,
                    height: 15,
                    color: Colors.grey[600],
                  ),
                  if (spacing < 1000)
                    Spacer(
                      flex: 1000 - spacing,
                    ),
                ],
              ),
              Row(
                children: [
                  if (spacing > 0)
                    Spacer(
                      flex: spacing,
                    ),
                  Text('min'),
                  if (spacing < 1000)
                    Spacer(
                      flex: 1000 - spacing,
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class ReportOutcomeModule extends ReportModuleContent {
  final bool primary;
  final Outcome outcome;

  const ReportOutcomeModule(StudyInstance instance, this.outcome, {@required this.primary}) : super(instance);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (outcome.title != null)
          Text(
            outcome.title,
            style: theme.textTheme.headline5,
          ),
        if (primary)
          Text(
            getResultText(),
            style: theme.textTheme.subtitle2,
          ),
        AspectRatio(aspectRatio: 2, child: getDiagram()),
      ],
    );
  }

  String getResultText() {
    return '';
  }

  Widget getDiagram() {
    switch (outcome.chartType) {
      case ChartType.BAR:
        return charts.BarChart(
          getBarData(),
          animate: true,
        );
      case ChartType.LINE:
        return Placeholder();
      default:
        print('Unknown chart type!');
        return Placeholder();
    }
  }

  List<charts.Series<_DiagramData, String>> getBarData() {
    Task task;
    task = instance.observations.firstWhere((element) => element.id == outcome.taskId, orElse: () => null);
    if (task != null) {
      if (task is QuestionnaireTask && outcome.questionId != null) {
        final data = <_DiagramData>[];
        switch (outcome.chartX) {
          case ChartX.INTERVENTION:
            final resultData = instance.getResultsByInterventionId(taskId: outcome.taskId);
            resultData.forEach((key, results) {
              final values = results.whereType<Result<QuestionnaireState>>().where((result) {
                final response = result.result.answers[outcome.questionId]?.response;
                return response != null && response is num;
              }).map<num>((result) => result.result.answers[outcome.questionId].response);

              if (values.isNotEmpty) {
                data.add(_DiagramData(key, values.reduce((a, b) => a + b) / values.length));
              }
            });
            break;
          default:
            print('Unknown x axis type.');
        }
        ;
        return [
          charts.Series<_DiagramData, String>(
            id: outcome.title,
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (dData, _) => dData.x,
            measureFn: (dData, _) => dData.y,
            data: data,
          )
        ];
      }
    }
    return [];
  }
}

class _DiagramData {
  final String x;
  final num y;

  _DiagramData(this.x, this.y);
}
