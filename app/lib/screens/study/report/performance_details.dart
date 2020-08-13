import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';

import '../../../routes.dart';
import '../../../util/intervention.dart';
import '../onboarding/intervention_card.dart';

class PerformanceDetailsScreen extends StatelessWidget {
  final ParseUserStudy reportStudy;

  static MaterialPageRoute routeFor({@required ParseUserStudy reportStudy}) => MaterialPageRoute(
      builder: (_) => PerformanceDetailsScreen(reportStudy), settings: RouteSettings(name: Routes.performanceDetails));

  const PerformanceDetailsScreen(this.reportStudy, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interventions =
        reportStudy.interventionSet.interventions.where((intervention) => !isBaseline(intervention)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Performance'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Overview of completion of all tasks', style: theme.textTheme.subtitle1),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                          Text('Interventions', style: theme.textTheme.headline6.copyWith(color: theme.primaryColor))),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: interventions.length,
                  itemBuilder: (context, index) =>
                      InterventionPerformanceBar(study: reportStudy, intervention: interventions[index]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                          Text('Observations', style: theme.textTheme.headline6.copyWith(color: theme.primaryColor))),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: reportStudy.observations.length,
                  itemBuilder: (context, index) =>
                      ObservationPerformanceBar(study: reportStudy, observation: reportStudy.observations[index]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InterventionPerformanceBar extends StatelessWidget {
  final Intervention intervention;
  final ParseUserStudy study;

  const InterventionPerformanceBar({@required this.intervention, @required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InterventionCard(intervention, showCheckbox: false, showTasks: false, showDescription: false),
            SizedBox(height: 8),
            ...intervention.tasks
                .map((task) => PerformanceBar(
                    task: task, completed: study.completedTasksFor(task), total: study.totalTaskCountFor(task)))
                .toList()
          ],
        ),
      ),
    );
  }
}

class ObservationPerformanceBar extends StatelessWidget {
  final Observation observation;
  final ParseUserStudy study;

  const ObservationPerformanceBar({@required this.observation, @required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PerformanceBar(
            task: observation,
            completed: study.completedTasksFor(observation),
            total: study.totalTaskCountFor(observation)),
      ),
    );
  }
}

class PerformanceBar extends StatelessWidget {
  final Task task;
  final int completed;
  final int total;

  const PerformanceBar({@required this.task, @required this.completed, @required this.total, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(task.title)),
            Text('$completed/$total'),
          ],
        ),
        SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            LinearProgressIndicator(
              minHeight: 20,
              value: completed / total,
            ),
            Center(
                child: Text('${(completed / total * 100).toStringAsFixed(2).replaceAll('.00', '')} %',
                    style: TextStyle(fontWeight: FontWeight.bold)))
          ],
        )
      ],
    );
  }
}
