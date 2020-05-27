import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../database/models/intervention.dart';
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

class _DashboardScreenState extends State<DashboardScreen> {
  List<Intervention> plannedInterventions;

  @override
  void initState() {
    super.initState();
    final interventions = [Intervention('Pain Killers'), Intervention('Exercise')];

    if (true) {
      // ABAB
      plannedInterventions = [interventions[0], interventions[1], interventions[0], interventions[1]];
    } else {
      // BBAA
      plannedInterventions = [interventions[1], interventions[1], interventions[0], interventions[0]];
    }
  }

  @override
  Widget build(BuildContext context) {
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
