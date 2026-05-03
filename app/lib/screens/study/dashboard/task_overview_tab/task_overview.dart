import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/progress_row.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_box.dart';
import 'package:studyu_app/spacing.dart';
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
    if (widget.scheduleToday == null || widget.scheduleToday!.isEmpty) {
      return list;
    }
    for (final taskInstance in widget.scheduleToday!) {
      list
        ..add(
          Padding(
            padding: const EdgeInsets.only(
              top: StudyUSpacing.space2,
              bottom: StudyUSpacing.space1,
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: theme.primaryColor, size: 16),
                const SizedBox(width: StudyUSpacing.space1),
                Text(
                  taskInstance.completionPeriod.formatted(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
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
                  : MdiIcons.fromString(widget.interventionIcon ?? 'help'),
              color: Colors.black.withValues(alpha: 0.4),
              size: 20,
            ),
          ),
        );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final currentIntervention = widget.subject!.getInterventionForDate(
      DateTime.now(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ProgressRow(subject: widget.subject),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: StudyUSpacing.space4,
            ),
            children: [
              const SizedBox(height: StudyUSpacing.space4),
              Text(
                AppLocalizations.of(context)!.intervention_current,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: StudyUSpacing.space2),
              _buildInterventionCard(currentIntervention),
              const SizedBox(height: StudyUSpacing.space4),
              Text(
                AppLocalizations.of(context)!.today_tasks,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: StudyUSpacing.space2),
              ...buildScheduleToday(context),
              const SizedBox(height: StudyUSpacing.space4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterventionCard(Intervention? intervention) {
    if (intervention == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: StudyUSpacing.space4,
        vertical: StudyUSpacing.space3,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: StudyUSpacing.space3),
          Expanded(
            child: Text(
              intervention.name ?? '',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info, color: Color(0xFF999999), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showInterventionInfo(intervention),
          ),
        ],
      ),
    );
  }

  void _showInterventionInfo(Intervention intervention) {
    showDialog(
      context: context,
      builder: (context) {
        final description = intervention.isBaseline()
            ? AppLocalizations.of(context)!.baseline_description
            : intervention.description;
        return AlertDialog(
          title: ListTile(
            leading: Icon(
              MdiIcons.fromString(intervention.icon),
              color: Theme.of(context).colorScheme.secondary,
            ),
            dense: true,
            title: Text(
              intervention.name ?? '',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          content: SingleChildScrollView(child: Text(description ?? '')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }
}
