import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_box.dart';
import 'package:studyu_app/screens/study/onboarding/calendar_overview.dart';
import 'package:studyu_app/widgets/intervention_card.dart';
import 'package:studyu_core/core.dart';

class TaskOverview extends StatefulWidget {
  final StudySubject? subject;
  final List<TaskInstance>? scheduleToday;
  final String? interventionIcon;

  const TaskOverview({
    required this.subject,
    required this.scheduleToday,
    super.key,
    this.interventionIcon,
  });

  @override
  State<TaskOverview> createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview> {
  void _navigateToReportIfStudyCompleted(BuildContext context) {
    if (widget.subject!.completedStudy) {
      // Workaround to reload dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.dashboard,
        (_) => false,
      );
    }
  }

  List<Widget> buildScheduleToday(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> list = [];
    for (final taskInstance in widget.scheduleToday!) {
      list
        ..add(
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              children: [
                Icon(Icons.access_time, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  taskInstance.completionPeriod.formatted(),
                  style: theme.textTheme.titleSmall!
                      .copyWith(fontSize: 16, color: theme.primaryColor),
                ),
              ],
            ),
          ),
        )
        ..add(
          TaskBox(
            taskInstance: taskInstance,
            onCompleted: () => _navigateToReportIfStudyCompleted(context),
            icon: Icon(
              taskInstance.task is Observation
                  ? MdiIcons.orderBoolAscendingVariant
                  : MdiIcons.fromString(widget.interventionIcon!),
            ),
          ),
        );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 8),
          // ProgressRow(subject: widget.subject),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: CalendarOverview(subject: widget.subject)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!.intervention_current,
                        style: theme.textTheme.titleLarge,),
                    // const Spacer(),
                    // Text(
                    //   '${widget.subject!.daysLeftForPhase(widget.subject!.getInterventionIndexForDate(DateTime.now()))} ${AppLocalizations.of(context)!.days_left}',
                    //   style: const TextStyle(color: primaryColor),
                    // )
                  ],
                ),
                const SizedBox(height: 8),
                InterventionCardTitle(
                    intervention:
                        widget.subject!.getInterventionForDate(DateTime.now()),),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.today_tasks,
                    style: theme.textTheme.titleLarge,),
              ],
            ),
          ),
          // Todo: find good way to calculate duration of intervention and display it
          ...buildScheduleToday(context),
          // Expanded(
          //   child: ListView(
          //     children: [
          //       ...buildScheduleToday(context),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
