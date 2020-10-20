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

class OverflowMenuItem {
  final String name;
  final IconData icon;
  final String routeName;

  OverflowMenuItem(this.name, this.icon, this.routeName);
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
            icon: Icon(MdiIcons.faceAgent),
            onPressed: () {
              Navigator.pushNamed(context, Routes.contact);
            },
          ),
          IconButton(
            tooltip: Nof1Localizations.of(context).translate('report_history'),
            icon: Icon(MdiIcons.chartBar),
            onPressed: () => Navigator.pushNamed(context, Routes.reportHistory),
          ),
          PopupMenuButton<OverflowMenuItem>(
            onSelected: (value) => Navigator.pushNamed(context, value.routeName),
            itemBuilder: (context) {
              return {
                OverflowMenuItem('Support', Icons.account_box, Routes.support),
                OverflowMenuItem(
                    Nof1Localizations.of(context).translate('FAQ'), MdiIcons.frequentlyAskedQuestions, Routes.faq),
                OverflowMenuItem(
                    Nof1Localizations.of(context).translate('about'), MdiIcons.informationOutline, Routes.about),
                OverflowMenuItem(
                    Nof1Localizations.of(context).translate('settings'), Icons.settings, Routes.appSettings),
              }.map((choice) {
                return PopupMenuItem<OverflowMenuItem>(
                  value: choice,
                  child: Row(children: [Icon(choice.icon, color: Colors.black), SizedBox(width: 8), Text(choice.name)]),
                );
              }).toList();
            },
          ),
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
