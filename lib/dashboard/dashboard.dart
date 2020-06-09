import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../database/models/interventions/intervention.dart';
import '../util/localization.dart';
import 'account_management.dart';
import 'contact_tab/contact.dart';
import 'task_overview_tab/task_overview.dart';

class DashboardScreenArguments {
  final List<Intervention> selectedInterventions;

  DashboardScreenArguments(this.selectedInterventions);
}

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  final List<Intervention> interventions;

  const DashboardScreen({Key key, this.interventions}) : super(key: key);

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
    final DashboardScreenArguments args = ModalRoute.of(context).settings.arguments;
    final interventions = args.selectedInterventions;

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
        title: Text(Nof1Localizations.of(context).translate('dashboard')),
        actions: [
          IconButton(
            tooltip: Nof1Localizations.of(context).translate('contact'),
            icon: Icon(MdiIcons.commentAccount),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Contact()));
            },
          ),
          IconButton(
            tooltip: Nof1Localizations.of(context).translate('settings'),
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Settings())),
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
