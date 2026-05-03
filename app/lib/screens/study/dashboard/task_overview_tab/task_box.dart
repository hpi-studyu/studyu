import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/spacing.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';

class TaskBox extends StatefulWidget {
  final TaskInstance taskInstance;
  final Icon icon;
  final Function() onCompleted;

  const TaskBox({
    super.key,
    required this.taskInstance,
    required this.icon,
    required this.onCompleted,
  });

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  Future<void> _navigateToTaskScreen() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(taskInstance: widget.taskInstance),
      ),
    );
    widget.onCompleted();
    // Rebuild widget
    setState(() {});
    if (mounted) scheduleNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    final completed = context
        .watch<AppState>()
        .activeSubject!
        .completedTaskInstanceForDay(
          widget.taskInstance.task.id,
          widget.taskInstance.completionPeriod,
          DateTime.now(),
        );
    final isPreview = context.read<AppState>().isPreview;
    final isInsidePeriod = widget.taskInstance.completionPeriod.contains(
      StudyUTimeOfDay.now(),
    );
    final isTaskOpen = !completed && isInsidePeriod || isPreview || kDebugMode;
    return Card(
      margin: const EdgeInsets.only(
        top: StudyUSpacing.space2,
        bottom: StudyUSpacing.space2,
      ),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: isTaskOpen ? _navigateToTaskScreen : () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: StudyUSpacing.space4,
            vertical: StudyUSpacing.space3,
          ),
          child: Row(
            children: [
              widget.icon,
              const SizedBox(width: StudyUSpacing.space3),
              Expanded(
                child: Text(
                  widget.taskInstance.task.title ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              if (isInsidePeriod || isPreview || completed)
                _CheckCircle(
                  completed: completed,
                  onTap: isTaskOpen ? _navigateToTaskScreen : null,
                )
              else
                Icon(
                  Icons.lock,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool completed;
  final VoidCallback? onTap;

  const _CheckCircle({required this.completed, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFF9800), width: 2.5),
        ),
        child: completed
            ? const Icon(Icons.check, color: Color(0xFFFF9800), size: 18)
            : const SizedBox.shrink(),
      ),
    );
  }
}
