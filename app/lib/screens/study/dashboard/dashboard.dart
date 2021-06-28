import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:quiver/collection.dart';
import 'package:studyu_core/core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../report/report_details.dart';
import 'task_overview_tab/task_overview.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class OverflowMenuItem {
  final String name;
  final IconData icon;
  final String routeName;
  final Function() onTap;

  OverflowMenuItem(this.name, this.icon, {this.routeName, this.onTap});
}

class _DashboardScreenState extends State<DashboardScreen> {
  StudySubject subject;
  Multimap<CompletionPeriod, Task> scheduleToday;

  @override
  void initState() {
    super.initState();
    subject = context.read<AppState>().activeSubject;
    scheduleToday = subject.scheduleFor(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Removes back button. We currently keep navigation stack to make developing easier
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context).dashboard),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).contact,
            icon: Icon(MdiIcons.faceAgent),
            onPressed: () {
              Navigator.pushNamed(context, Routes.contact);
            },
          ),
          IconButton(
            tooltip: 'Current report',
            icon: Icon(MdiIcons.chartBar),
            onPressed: () => Navigator.push(context, ReportDetailsScreen.routeFor(subject: subject)),
          ),
          PopupMenuButton<OverflowMenuItem>(
            onSelected: (value) {
              if (value.routeName != null) {
                Navigator.pushNamed(context, value.routeName);
              } else if (value.onTap != null) {
                value.onTap();
              }
            },
            itemBuilder: (context) {
              return [
                OverflowMenuItem(AppLocalizations.of(context).report_history, MdiIcons.history,
                    routeName: Routes.reportHistory),
                OverflowMenuItem(AppLocalizations.of(context).faq, MdiIcons.frequentlyAskedQuestions,
                    routeName: Routes.faq),
                OverflowMenuItem(AppLocalizations.of(context).settings, Icons.settings, routeName: Routes.appSettings),
                OverflowMenuItem(AppLocalizations.of(context).what_is_studyu, MdiIcons.helpCircleOutline,
                    routeName: Routes.about),
                OverflowMenuItem(AppLocalizations.of(context).about, MdiIcons.informationOutline, onTap: () async {
                  final iconAuthors = ['Kiranshastry'];
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  showAboutDialog(
                      context: context,
                      applicationIcon: Image(image: AssetImage('assets/images/icon.png'), height: 32),
                      applicationVersion: packageInfo.version,
                      children: [
                        RichText(
                          text: TextSpan(style: TextStyle(color: Colors.black), children: [
                            TextSpan(text: 'Icons from '),
                            TextSpan(
                                style: TextStyle(color: Colors.blue),
                                text: 'www.flaticon.com',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launch('https://www.flaticon.com/');
                                  }),
                            TextSpan(text: ' made by'),
                          ]),
                        ),
                        SizedBox(height: 8),
                        Column(
                          children: iconAuthors
                              .map((author) => InkWell(
                                    onTap: () {
                                      launch(
                                          'https://www.flaticon.com/authors/${author.replaceAll(RegExp(r'\s|_'), '-')}');
                                    },
                                    child: Text(
                                      author,
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ))
                              .toList(),
                        )
                      ]);
                })
              ].map((choice) {
                return PopupMenuItem<OverflowMenuItem>(
                  value: choice,
                  child: Row(children: [Icon(choice.icon, color: Colors.black), SizedBox(width: 8), Text(choice.name)]),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: subject.completedStudy
          ? StudyFinishedPlaceholder()
          : TaskOverview(
              subject: subject,
              scheduleToday: scheduleToday,
              interventionIcon: subject.getInterventionForDate(DateTime.now())?.icon),
      bottomSheet: kDebugMode && !subject.completedStudy
          ? TextButton(
              onPressed: () async {
                await subject.setStartDateBackBy(days: 1);
                setState(() {
                  scheduleToday = subject.scheduleFor(DateTime.now());
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
          Text(AppLocalizations.of(context).completed_study,
              style: TextStyle(fontSize: 20, color: theme.primaryColor, fontWeight: FontWeight.bold)),
          space,
          OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, Routes.reportHistory),
              icon: Icon(MdiIcons.history, size: fontSize),
              label: Text(AppLocalizations.of(context).report_history, style: textStyle)),
          space,
          OutlinedButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, Routes.studySelection, (_) => false),
              icon: Icon(MdiIcons.clipboardArrowRightOutline, size: fontSize),
              label: Text(AppLocalizations.of(context).study_selection, style: textStyle)),
        ],
      ),
    ));
  }
}
