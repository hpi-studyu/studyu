import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import './complation_period_editor.dart';
import 'package:provider/provider.dart';
import 'package:studyu_designer_v2/features/legacy/designer/app_state.dart';
import '../../widgets/task/reminder_editor.dart';

class TaskScheduleEditorSection extends StatefulWidget {
  final Task task;

  const TaskScheduleEditorSection({required this.task, Key? key}) : super(key: key);

  @override
  _TaskScheduleEditorSectionState createState() => _TaskScheduleEditorSectionState();
}

class _TaskScheduleEditorSectionState extends State<TaskScheduleEditorSection> {
  void _addReminder() {
    setState(() {
      widget.task.schedule.reminders.add(StudyUTimeOfDay());
    });
    context.read<AppState>().updateDelegate();
  }

  void _removeReminder(int index) {
    setState(() {
      widget.task.schedule.reminders.removeAt(index);
    });
    context.read<AppState>().updateDelegate();
  }

  void _addCompletionPeriod() {
    final completionPeriod =
        CompletionPeriod(unlockTime: StudyUTimeOfDay(hour: 8), lockTime: StudyUTimeOfDay(hour: 20));
    setState(() {
      widget.task.schedule.completionPeriods.add(completionPeriod);
    });
    context.read<AppState>().updateDelegate();
  }

  void _removeCompletionPeriod(int index) {
    setState(() {
      widget.task.schedule.completionPeriods.removeAt(index);
    });
    context.read<AppState>().updateDelegate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduling',
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 16),
        Text('Participants can complete one task from', style: theme.textTheme.bodyText1),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.task.schedule.completionPeriods.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (buildContext, index) {
            return CompletionPeriodEditor(
              key: UniqueKey(),
              completionPeriod: widget.task.schedule.completionPeriods[index],
              isFirst: index == 0,
              remove: () => _removeCompletionPeriod(index),
            );
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(primary: Colors.green),
          icon: const Icon(Icons.add),
          onPressed: _addCompletionPeriod,
          label: const Text('Add completion period'),
        ),
        const SizedBox(height: 32),
        Text('Remind participant at', style: theme.textTheme.bodyText1),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.task.schedule.reminders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (buildContext, index) {
            return ReminderEditor(
              key: UniqueKey(),
              reminder: widget.task.schedule.reminders[index],
              remove: () => _removeReminder(index),
            );
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(primary: Colors.green),
          icon: const Icon(Icons.add),
          onPressed: _addReminder,
          label: const Text('Add reminder time'),
        ),
      ],
    );
  }
}