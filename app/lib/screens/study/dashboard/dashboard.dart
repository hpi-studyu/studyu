import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quiver/collection.dart';
import 'package:studyou_core/models/models.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';
import 'task_overview_tab/task_overview.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StudyInstance study;
  Multimap<Time, Task> scheduleToday;

  @override
  void initState() {
    super.initState();
    study = context.read<AppModel>().activeStudy;

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
      for (final schedule in observation.schedule) {
        if (schedule is FixedSchedule) {
          scheduleToday.add(schedule.time, observation);
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
        child: TaskOverview(study: study, scheduleToday: scheduleToday),
      ),
    );
  }
}
