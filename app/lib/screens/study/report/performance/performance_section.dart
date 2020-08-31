import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:studyou_core/models/models.dart';

import '../../../../util/localization.dart';
import '../generic_section.dart';

class PerformanceSection extends GenericSection {
  const PerformanceSection(ParseUserStudy instance, {Function onTap}) : super(instance, onTap: onTap);

  // TODO move to model
  final minimumRatio = 0.1;
  final maximum = 4;

  @override
  Widget buildContent(BuildContext context) {
    final interventions =
        instance.interventionSet.interventions.where((intervention) => intervention.id != '__baseline').toList();
    final interventionProgress = interventions.map((intervention) {
      final countableInterventions = getCountableObservationAmount(intervention);
      return min<double>(countableInterventions == 0 ? 0 : countableInterventions / maximum, 1);
    }).toList();
    return interventions.length != 2 || instance.reportSpecification?.primary == null
        ? Center(
            child: Text('ERROR!'),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${Nof1Localizations.of(context).translate('current_power_level')}: ${getPowerLevelDescription(context, interventionProgress)}',
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PerformanceBar(
                          progress: interventionProgress[i],
                          minimum: minimumRatio,
                        ),
                      );
                    }
                  }),
            ],
          );
  }

  String getPowerLevelDescription(BuildContext context, List<num> interventionProgress) {
    if (interventionProgress.any((progress) => progress < minimumRatio)) {
      return Nof1Localizations.of(context).translate('not_enough_data');
    } else if (interventionProgress.any((progress) => progress < 1)) {
      return Nof1Localizations.of(context).translate('barely_enough_data');
    } else {
      return Nof1Localizations.of(context).translate('enough_data');
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
