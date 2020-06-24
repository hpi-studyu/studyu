import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';

import '../../database/models/observations/tasks/questionnaire_task.dart';
import '../../database/models/tasks/fixed_schedule.dart';
import '../../database/models/tasks/task.dart';
import '../../tasks/pain_rating_task.dart';
import '../../tasks/video_task.dart';
import '../dashboard.dart';
import 'progress_row.dart';
import 'task_box.dart';

class TaskOverview extends StatefulWidget {
  final List<PlannedIntervention> plannedInterventions;
  final Multimap<Time, Task> scheduleToday;

  const TaskOverview({@required this.plannedInterventions, @required this.scheduleToday, Key key}) : super(key: key);
  @override
  _TaskOverviewState createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview> {
  String interventionDateString(PlannedIntervention plannedIntervention) {
    String dateString(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
    }

    return '${dateString(plannedIntervention.startDate)} - ${dateString(plannedIntervention.endDate)}';
  }

  List<Widget> buildScheduleToday(BuildContext context) {
    final theme = Theme.of(context);
    final result = <Widget>[];

    for (final key in widget.scheduleToday.keys) {
      result.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(key.toString(), style: theme.textTheme.subtitle2.copyWith(color: Colors.black)),
      ));
      for (final task in widget.scheduleToday[key]) {
        Widget taskWidget;
        if (task is QuestionnaireTask) {
          taskWidget = TaskBox(task: PainRatingTask(task.title, task.title));
        } else {
          taskWidget = TaskBox(
              task: VideoTask(
            task.title,
            task.title,
            'assets/rick-roll.mp4',
          ));
        }
        result.add(taskWidget);
      }
    }

    return result;
/*
    return widget.scheduleToday.keys.map((key) => {
    widget.scheduleToday[key].map((task) => {
    return TaskBox(
    task: PainRatingTask(
    Nof1Localizations.of(context).translate('survey'),
    Nof1Localizations.of(context).translate('survey_test'),
    ))
    })
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        ProgressRow(plannedInterventions: widget.plannedInterventions),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(interventionDateString(widget.plannedInterventions[1]),
                    style: theme.textTheme.subtitle1.copyWith(color: Colors.black)),
              ),
              ...buildScheduleToday(context),
            ],
          ),
        ),
      ],
    );
  }
}

class TaskOverviewModel extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  DateTime get currentDate => DateTime.now();

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
