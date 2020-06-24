import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quiver/collection.dart';

import '../database/models/interventions/intervention.dart';
import '../database/models/study_instance.dart';
import '../database/models/tasks/fixed_schedule.dart';
import '../database/models/tasks/task.dart';
import '../routes.dart';
import '../study_onboarding/app_state.dart';
import '../util/localization.dart';
import 'task_overview_tab/task_overview.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class PlannedIntervention {
  final Intervention intervention;
  final DateTime startDate;
  final DateTime endDate;

  PlannedIntervention(this.intervention, this.startDate, this.endDate);
}

class _DashboardScreenState extends State<DashboardScreen> {
  StudyInstance study;
  List<Intervention> interventions;
  List<PlannedIntervention> plannedInterventions;
  Multimap<Time, Task> scheduleToday;

  @override
  void initState() {
    super.initState();
    // TODO: dashboard should read from a different model connected to parse UserStudy object
    study = context.read<AppModel>().activeStudy;
    interventions = study.interventionSet.interventions.toList();
    plannedInterventions = [];
    for (var i = 0; i < study.interventionOrder.length; i++) {
      final id = study.interventionOrder[i];
      plannedInterventions.add(PlannedIntervention(
        interventions.firstWhere((intervention) => intervention.id == id, orElse: () => null),
        DateTime.now().add(Duration(days: 7 * i)),
        DateTime.now().add(Duration(days: 6)),
      ));
    }

    final activeIntervention = study.getInterventionForDate(DateTime.now());

    scheduleToday = Multimap<Time, Task>();
    for (final task in activeIntervention.tasks) {
      for (final schedule in task.schedule) {
        if (schedule is FixedSchedule) {
          scheduleToday.add(schedule.time, task);
        }
      }
    }
    for (final observation in study.observations) {
      for (final task in observation.tasks) {
        for (final schedule in task.schedule) {
          if (schedule is FixedSchedule) {
            scheduleToday.add(schedule.time, task);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Removes back button. We currently keep navigation stack to make developing easier
        automaticallyImplyLeading: false,
        title: Text(Nof1Localizations.of(context).translate('dashboard')),
        actions: [
          IconButton(
            tooltip: Nof1Localizations.of(context).translate('contact'),
            icon: Icon(MdiIcons.commentAccount),
            onPressed: () {
              Navigator.pushNamed(context, Routes.contact);
            },
          ),
          IconButton(
            tooltip: Nof1Localizations.of(context).translate('settings'),
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, Routes.appSettings),
          ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context) => TaskOverviewModel(),
        child: TaskOverview(plannedInterventions: plannedInterventions, scheduleToday: scheduleToday),
      ),
    );
  }
}
