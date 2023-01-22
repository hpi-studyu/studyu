import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';

import '../../../models/app_state.dart';
import 'intervention/checkmark_task_widget.dart';
import 'observation/questionnaire_task_widget.dart';

class TaskScreen extends StatefulWidget {
  final Task task;
  final String taskId;

  static MaterialPageRoute<bool> routeFor({@required Task task}) => MaterialPageRoute(
    builder: (_) => TaskScreen(task: task),
  );

  const TaskScreen({@required this.task, this.taskId, Key key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Task task;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final subject = context.watch<AppState>().activeSubject;
    if (widget.task != null) {
      final tasks = <Task>[
    ...subject.study.observations.where((observation) => observation.id == widget.task.id),
    ...subject.selectedInterventions
        .map((intervention) => intervention.tasks.where((task) => task.id == widget.task.id))
        .expand((task) => task)
      ];
      task = tasks.first;
    } else if (widget.taskId != null) {
      final tasks = <Task>[
        ...subject.study.observations.where((observation) => observation.id == widget.taskId),
        ...subject.selectedInterventions
            .map((intervention) => intervention.tasks.where((task) => task.id == widget.taskId))
            .expand((task) => task)
      ];
      if (tasks.isEmpty) {
        print('No task found with ID ${widget.taskId}');
      } else if (tasks.length > 1) {
        print('Too many tasks found with ID ${widget.taskId}');
      } else {
        task = tasks.first;
      }
    }
    if (task == null) {
      Navigator.pop(context, false);
    }
  }

  Widget _buildTask() {
    switch (task.runtimeType) {
      case CheckmarkTask:
        return CheckmarkTaskWidget(task: task as CheckmarkTask, key: UniqueKey());
      case QuestionnaireTask:
        return QuestionnaireTaskWidget(task: task as QuestionnaireTask, key: UniqueKey());
      default:
        print('${task.runtimeType} is not a supported Task!');
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(task.title, style: theme.textTheme.headline4.copyWith(fontSize: 24)),
              const SizedBox(height: 20),
              _buildTask(),
            ],
          ),
        ),
      ),
    );
  }
}
