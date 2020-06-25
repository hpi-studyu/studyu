import 'package:Nof1/util/localization.dart';
import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';

import '../../database/models/observations/tasks/questionnaire_task.dart';
import '../../database/models/study_instance.dart';
import '../../database/models/tasks/fixed_schedule.dart';
import '../../database/models/tasks/task.dart';
import '../../tasks/pain_rating_task.dart';
import '../../tasks/video_task.dart';
import 'progress_row.dart';
import 'task_box.dart';

class TaskOverview extends StatefulWidget {
  final StudyInstance study;
  final Multimap<Time, Task> scheduleToday;

  const TaskOverview({@required this.study, @required this.scheduleToday, Key key}) : super(key: key);
  @override
  _TaskOverviewState createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview> {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ProgressRow(study: widget.study),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Current Intervention', style: theme.textTheme.headline6)),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(widget.study.getInterventionForDate(DateTime.now()).name)),
        // Todo: display duration of intervention
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(Nof1Localizations.of(context).translate('today_tasks'), style: theme.textTheme.headline6)),
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

class TaskOverviewModel extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  DateTime get currentDate => DateTime.now();

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
