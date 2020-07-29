import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../models/app_state.dart';
import '../onboarding/intervention_card.dart';

class PerformanceScreen extends StatefulWidget {
  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  StudyInstance study;

  @override
  void initState() {
    super.initState();
    study = context.read<AppModel>().activeStudy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  itemCount: study.interventionSet.interventions.length,
                  itemBuilder: (context, index) => InterventionPerformanceBar(
                      study: study, intervention: study.interventionSet.interventions[index]),
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
                  itemCount: study.observations.length,
                  itemBuilder: (context, index) =>
                      ObservationPerformanceBar(study: study, observation: study.observations[index]),
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
  final StudyInstance study;

  const InterventionPerformanceBar({@required this.intervention, @required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
  final StudyInstance study;

  const ObservationPerformanceBar({@required this.observation, @required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
