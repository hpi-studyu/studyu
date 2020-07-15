import 'package:flutter/material.dart';
import 'package:nof1_models/models/models.dart';
import 'package:quiver/collection.dart';

import '../../util/localization.dart';
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

    return widget.scheduleToday.keys
        .expand((time) => [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(time.toString(), style: theme.textTheme.subtitle2.copyWith(color: Colors.black)),
              ),
              ...widget.scheduleToday[time].map((task) => TaskBox(task: task))
            ])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ProgressRow(study: widget.study),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 8),
              Text('Current Intervention', style: theme.textTheme.headline6),
              SizedBox(height: 8),
              Text(widget.study.getInterventionForDate(DateTime.now()).name),
              SizedBox(height: 8),
              Text(Nof1Localizations.of(context).translate('today_tasks'), style: theme.textTheme.headline6)
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

class TaskOverviewModel extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  DateTime get currentDate => DateTime.now();

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
