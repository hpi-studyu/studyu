import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import '../../../../routes.dart';
import '../../../../widgets/intervention_card.dart';

class PerformanceDetailsScreen extends StatelessWidget {
  final StudySubject reportSubject;

  static MaterialPageRoute routeFor({@required StudySubject subject}) => MaterialPageRoute(
        builder: (_) => PerformanceDetailsScreen(subject),
        settings: const RouteSettings(name: Routes.performanceDetails),
      );

  const PerformanceDetailsScreen(this.reportSubject, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interventions =
        reportSubject.selectedInterventions.where((intervention) => !intervention.isBaseline()).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).performance),
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
                  child: Text(AppLocalizations.of(context).performance_overview, style: theme.textTheme.titleMedium),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context).performance_overview_interventions,
                      style: theme.textTheme.titleLarge.copyWith(color: theme.primaryColor),
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: interventions.length,
                  itemBuilder: (context, index) =>
                      InterventionPerformanceBar(subject: reportSubject, intervention: interventions[index]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context).performance_overview_observations,
                      style: theme.textTheme.titleLarge.copyWith(color: theme.primaryColor),
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: reportSubject.study.observations.length,
                  itemBuilder: (context, index) => ObservationPerformanceBar(
                    subject: reportSubject,
                    observation: reportSubject.study.observations[index],
                  ),
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
  final StudySubject subject;

  const InterventionPerformanceBar({@required this.intervention, @required this.subject, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InterventionCard(intervention, showTasks: false, showDescription: false),
            const SizedBox(height: 8),
            ...intervention.tasks.map(
              (task) => PerformanceBar(
                task: task,
                completed: subject.completedTasksFor(task),
                total: subject.totalTaskCountFor(task),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ObservationPerformanceBar extends StatelessWidget {
  final Observation observation;
  final StudySubject subject;

  const ObservationPerformanceBar({@required this.observation, @required this.subject, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PerformanceBar(
          task: observation,
          completed: subject.completedTasksFor(observation),
          total: subject.totalTaskCountFor(observation),
        ),
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
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            LinearProgressIndicator(
              minHeight: 20,
              value: completed / total,
            ),
            Center(
              child: Text(
                '${(completed / total * 100).toStringAsFixed(2).replaceAll('.00', '')} %',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        )
      ],
    );
  }
}
