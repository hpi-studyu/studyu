import 'package:flutter/foundation.dart';
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
  ParseUserStudy study;
  Multimap<Time, Task> scheduleToday;

  @override
  void initState() {
    super.initState();
    study = context.read<AppModel>().activeStudy;
    scheduleToday = study.scheduleFor(DateTime.now());
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
            tooltip: Nof1Localizations.of(context).translate('report_history'),
            icon: Icon(MdiIcons.history),
            onPressed: () => Navigator.pushNamed(context, Routes.reportHistory),
          ),
          IconButton(
            tooltip: Nof1Localizations.of(context).translate('settings'),
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, Routes.appSettings),
          )
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context) => TaskOverviewModel(),
        child: TaskOverview(
            study: study,
            scheduleToday: scheduleToday,
            interventionIcon: study.getInterventionForDate(DateTime.now()).icon),
      ),
      bottomSheet: kDebugMode
          ? FlatButton(
              onPressed: () {
                setState(() {
                  study.setStartDateBackBy(days: 1);
                  scheduleToday = study.scheduleFor(DateTime.now());
                });
              },
              child: Text('next day'),
            )
          : null,
    );
  }
}
