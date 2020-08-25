import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:studyou_core/models/models.dart';

import '../../../routes.dart';
import '../../../util/localization.dart';
import 'performance_details.dart';

class ReportDetailsScreen extends StatelessWidget {
  final ParseUserStudy reportStudy;

  static MaterialPageRoute routeFor({@required ParseUserStudy reportStudy}) => MaterialPageRoute(
      builder: (_) => ReportDetailsScreen(reportStudy), settings: RouteSettings(name: Routes.reportDetails));

  const ReportDetailsScreen(this.reportStudy, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final outcome = reportStudy.reportSpecification.primary;

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
              ReportModule(ReportAverageModule(reportStudy, reportStudy.reportSpecification.primary, primary: true)),
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
  final ParseUserStudy instance;

  const ReportModuleContent(this.instance);
}

class ReportGeneralDetailsModule extends ReportModuleContent {
  const ReportGeneralDetailsModule(ParseUserStudy instance) : super(instance);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(instance.description),
        ],
      );
}

class ReportPerformanceModule extends ReportModuleContent {
  const ReportPerformanceModule(ParseUserStudy instance) : super(instance);

  // TODO move to model
  final minimum = 0.1;
  final maximum = 100;

  @override
  Widget build(BuildContext context) {
    final interventions =
        instance.interventionSet.interventions.where((intervention) => intervention.id != '__baseline').toList();
    return interventions.length != 2 || instance.reportSpecification?.primary == null
        ? Center(
            child: Text('ERROR!'),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${Nof1Localizations.of(context).translate('current_power_level')}: ${getPowerLevelDescription(0)}',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: interventions.length * 2,
                  itemBuilder: (context, index) {
                    final i = (index / 2).floor();
                    if (index.isEven) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          interventions[i].name,
                        ),
                      );
                    } else {
                      final countableInterventions = getCountableObservationAmount(interventions[i]);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PerformanceBar(
                          progress: countableInterventions == 0 ? 0 : countableInterventions / maximum,
                          minimum: minimum,
                        ),
                      );
                    }
                  }),
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

  int getCountableObservationAmount(Intervention intervention) {
    var interventionsPerDay = 0;
    for (final interventionTask in intervention.tasks) {
      interventionsPerDay += interventionTask.schedule.length;
    }

    var countable = 0;
    instance.getResultsByDate(interventionId: intervention.id).values.forEach((resultList) {
      if (resultList
              .where((result) => intervention.tasks.any((interventionTask) => interventionTask.id == result.taskId))
              .length ==
          interventionsPerDay) {
        countable += resultList
            .where((result) => instance.observations.any((observation) => observation.id == result.taskId))
            .length;
      }
    });
    return countable;
    /*final primaryOutcome = instance.reportSpecification.outcomes[0];
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
    return Normal.cdf(-1.96 + ((mean0 - mean1) / sqrt(pow(sD, 2) / (results[0].length + results[1].length)))) +
        Normal.cdf(-1.96 - ((mean0 - mean1) / sqrt(pow(sD, 2) / (results[0].length + results[1].length))));*/
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

class ReportAverageModule extends ReportModuleContent {
  final bool primary;
  final AverageSection section;

  const ReportAverageModule(ParseUserStudy instance, this.section, {@required this.primary}) : super(instance);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (section.title != null)
          Text(
            section.title,
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
    return charts.BarChart(
      getBarData(),
      domainAxis: charts.OrdinalAxisSpec(),
      animate: true,
    );
  }

  List<charts.Series<_DiagramDatum, String>> getBarData() {
    var values = section.resultProperty.retrieveFromResults(instance);
    final data = values.entries
        .map((e) => _DiagramDatum(
            instance.getDayOfStudyFor(e.key).toString(), e.value, e.key, instance.getInterventionForDate(e.key).id))
        .toList();
    return [
      charts.Series<_DiagramDatum, String>(
        id: section.title,
        colorFn: (datum, __) {
          var index = instance.interventionSet.interventions.indexWhere((element) => element.id == datum.intervention);
          return [
            charts.MaterialPalette.blue.shadeDefault,
            charts.MaterialPalette.deepOrange.shadeDefault,
            charts.MaterialPalette.gray.shadeDefault,
          ][index];
        },
        domainFn: (dData, _) => dData.x,
        measureFn: (dData, _) => dData.y,
        data: data,
      )
    ];
  }
}

class _DiagramDatum {
  final String x;
  final DateTime timestamp;
  final String intervention;
  final num y;

  _DiagramDatum(this.x, this.y, this.timestamp, this.intervention);
}
