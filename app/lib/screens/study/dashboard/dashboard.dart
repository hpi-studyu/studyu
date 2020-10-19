import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quiver/collection.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
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
    study = context.read<AppState>().activeStudy;
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
      body: study.completedStudy
          ? StudyFinishedPlaceholder()
          : TaskOverview(
              study: study,
              scheduleToday: scheduleToday,
              interventionIcon: study.getInterventionForDate(DateTime.now())?.icon),
      bottomSheet: kDebugMode && !study.completedStudy
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

class StudyFinishedPlaceholder extends StatelessWidget {
  static const space = SizedBox(height: 80);

  @override
  Widget build(BuildContext context) {
    const fontSize = 30.0;
    final textStyle = TextStyle(fontSize: fontSize);
    final theme = Theme.of(context);
    return Center(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Nof1Localizations.of(context).translate('completed_study'),
              style: TextStyle(fontSize: 20, color: theme.primaryColor, fontWeight: FontWeight.bold)),
          space,
          OutlineButton.icon(
              onPressed: () => Navigator.pushNamed(context, Routes.reportHistory),
              icon: Icon(MdiIcons.history, size: fontSize),
              label: Text(Nof1Localizations.of(context).translate('report_history'), style: textStyle)),
          space,
          OutlineButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, Routes.studySelection, (_) => false),
              icon: Icon(MdiIcons.clipboardArrowRightOutline, size: fontSize),
              label: Text(Nof1Localizations.of(context).translate('study_selection'), style: textStyle)),
        ],
      ),
    ));
  }
}
