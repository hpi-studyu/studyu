import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quiver/collection.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_core/core.dart';

import '../../../../routes.dart';
import '../../../../widgets/intervention_card.dart';
import 'progress_row.dart';
import 'task_box.dart';

class TaskOverview extends StatefulWidget {
  final StudySubject subject;
  final Multimap<CompletionPeriod, Task> scheduleToday;
  final String interventionIcon;

  const TaskOverview({@required this.subject, @required this.scheduleToday, Key key, this.interventionIcon})
      : super(key: key);
  @override
  _TaskOverviewState createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview> {
  void _navigateToReportIfStudyCompleted(BuildContext context) {
    if (widget.subject.completedStudy) {
      // Workaround to reload dashboard
      Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard, (_) => false);
    }
  }

  List<Widget> buildScheduleToday(BuildContext context) {
    final theme = Theme.of(context);

    return widget.scheduleToday.keys
        .expand(
          (completionPeriod) => [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: theme.primaryColor),
                  SizedBox(width: 8),
                  Text(completionPeriod.toString(),
                      style: theme.textTheme.subtitle2.copyWith(fontSize: 16, color: theme.primaryColor)),
                ],
              ),
            ),
            ...widget.scheduleToday[completionPeriod].map(
              (task) => TaskBox(
                task: task,
                completionPeriod: completionPeriod,
                onCompleted: () => _navigateToReportIfStudyCompleted(context),
                icon: Icon(
                  task is Observation
                      ? MdiIcons.orderBoolAscendingVariant
                      : MdiIcons.fromString(widget.interventionIcon),
                ),
              ),
            )
          ],
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 8),
        ProgressRow(subject: widget.subject),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 16),
              Row(
                children: [
                  Text(AppLocalizations.of(context).intervention_current, style: theme.textTheme.headline6),
                  Spacer(),
                  Text(
                      '${widget.subject.daysLeftForPhase(widget.subject.getInterventionIndexForDate(DateTime.now()))} days left',
                      style: TextStyle(color: primaryColor))
                ],
              ),
              SizedBox(height: 8),
              InterventionCardTitle(intervention: widget.subject.getInterventionForDate(DateTime.now())),
              SizedBox(height: 8),
              Text(AppLocalizations.of(context).today_tasks, style: theme.textTheme.headline6)
            ])),
        // Todo: find good way to calculate duration of intervention and display it
        Expanded(
          child: ListView(
            children: [
              ...buildScheduleToday(context),
            ],
          ),
        ),
      ],
    );
  }
}
