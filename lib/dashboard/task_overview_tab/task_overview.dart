import 'package:flutter/material.dart';

import '../../database/models/intervention.dart';
import '../../tasks/pain_rating_task.dart';
import '../../tasks/video_task.dart';
import '../../util/localization.dart';
import 'progress_row.dart';
import 'task_box.dart';

class TaskOverview extends StatefulWidget {
  final List<Intervention> plannedInterventions;

  const TaskOverview({Key key, @required this.plannedInterventions}) : super(key: key);
  @override
  _TaskOverviewState createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview> {
  final DateTime _startDate = DateTime.now().subtract(Duration(days: 9));
  final DateTime _endDate = DateTime.now().add(Duration(days: 15));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ProgressRow(plannedInterventions: widget.plannedInterventions),
        Expanded(
          child: ListView(
            children: [
              TaskBox(
                  task: VideoTask(
                Nof1Localizations.of(context).translate('video_task'),
                Nof1Localizations.of(context).translate('video_test'),
                'assets/rick-roll.mp4',
              )),
              TaskBox(
                  task: PainRatingTask(
                Nof1Localizations.of(context).translate('survey'),
                Nof1Localizations.of(context).translate('survey_test'),
              ))
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
