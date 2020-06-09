import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../database/models/interventions/intervention.dart';
import '../routes.dart';
import '../util/localization.dart';
import 'task_overview_tab/task_overview.dart';

class DashboardScreenArguments {
  final List<Intervention> selectedInterventions;

  const DashboardScreenArguments(this.selectedInterventions);
}

class DashboardScreen extends StatefulWidget {
  final List<Intervention> interventions;

  const DashboardScreen(this.interventions, {Key key}) : super(key: key);

  factory DashboardScreen.fromRouteArgs(DashboardScreenArguments args) => DashboardScreen(args.selectedInterventions);

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
  List<PlannedIntervention> plannedInterventions;

  @override
  Widget build(BuildContext context) {
    // ABAB
    final plannedInterventions = [
      PlannedIntervention(widget.interventions[0], DateTime.now(), DateTime.now().add(Duration(days: 6))),
      PlannedIntervention(
          widget.interventions[1], DateTime.now().add(Duration(days: 7)), DateTime.now().add(Duration(days: 13))),
      PlannedIntervention(
          widget.interventions[0], DateTime.now().add(Duration(days: 14)), DateTime.now().add(Duration(days: 20))),
      PlannedIntervention(
          widget.interventions[1], DateTime.now().add(Duration(days: 21)), DateTime.now().add(Duration(days: 27)))
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
