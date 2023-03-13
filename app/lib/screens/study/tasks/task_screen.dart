import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/intervention_card.dart';
import 'package:studyu_core/core.dart';

import 'intervention/checkmark_task_widget.dart';
import 'observation/questionnaire_task_widget.dart';

class TaskScreen extends StatefulWidget {
  final TaskInstance taskInstance;

  static MaterialPageRoute<bool> routeFor({@required TaskInstance taskInstance}) => MaterialPageRoute(
        builder: (_) => TaskScreen(taskInstance: taskInstance),
      );

  const TaskScreen({@required this.taskInstance, Key key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  TaskInstance taskInstance;
  StudySubject subject;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subject = context.watch<AppState>().activeSubject;
    taskInstance = TaskInstance.fromInstanceId(widget.taskInstance.id, study: subject.study);
  }

  Widget _buildTask() {
    switch (taskInstance.task.runtimeType) {
      case CheckmarkTask:
        return CheckmarkTaskWidget(
          task: taskInstance.task as CheckmarkTask,
          key: UniqueKey(),
          completionPeriod: taskInstance.completionPeriod,
        );
      case QuestionnaireTask:
        return QuestionnaireTaskWidget(
          task: taskInstance.task as QuestionnaireTask,
          key: UniqueKey(),
          completionPeriod: taskInstance.completionPeriod,
        );
      default:
        print('${taskInstance.task.runtimeType} is not a supported Task!');
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interventionCard = InterventionCardTitle(
        intervention: subject.getInterventionForDate(DateTime.now()));
    return Scaffold(
      appBar: AppBar(
        title: Text(taskInstance.task.title ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: Text(
                        taskInstance.task.title ?? '',
                        style: theme.textTheme.headlineMedium.copyWith(fontSize: 24),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.grey),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: ListTile(
                            dense: true,
                            title: Text(taskInstance.task.title, style: theme.textTheme.titleLarge),
                          ),
                          content: HtmlText(taskInstance.task.header),
                        );
                      },
                    ),
                  ),
                ]
            ),
              const SizedBox(height: 20),
              _buildTask(),
            ],
          ),
        ),
      ),
    );
  }
}
