import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../database/models/interventions/intervention.dart';
import '../routes.dart';
import '../study_onboarding/onboarding_model.dart';
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
  @override
  Widget build(BuildContext context) {
    // TODO: dashboard should read from a different model connected to parse UserStudy object
    final interventions = context.read<OnboardingModel>().selectedInterventions;

    // ABAB
    final plannedInterventions = [
      PlannedIntervention(interventions[0], DateTime.now(), DateTime.now().add(Duration(days: 6))),
      PlannedIntervention(
          interventions[1], DateTime.now().add(Duration(days: 7)), DateTime.now().add(Duration(days: 13))),
      PlannedIntervention(
          interventions[0], DateTime.now().add(Duration(days: 14)), DateTime.now().add(Duration(days: 20))),
      PlannedIntervention(
          interventions[1], DateTime.now().add(Duration(days: 21)), DateTime.now().add(Duration(days: 27)))
    ];
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
        child: TaskOverview(plannedInterventions: plannedInterventions),
      ),
    );
  }
}
