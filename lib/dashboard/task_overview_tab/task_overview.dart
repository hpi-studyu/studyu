import 'package:Nof1/tasks/pain_rating_task.dart';
import 'package:flutter/material.dart';

import '../../tasks/video_task.dart';
import '../../util/localization.dart';
import 'calendar_row.dart';
import 'task_box.dart';

class TaskOverview extends StatefulWidget {
  @override
  _TaskOverviewState createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview> {
  final DateTime _startDate = DateTime.now().subtract(Duration(days: 8));
  final DateTime _endDate = DateTime.now().add(Duration(days: 60));

  void onSelect(DateTime date) {
    print('Selected Date -> $date');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CalendarRow(
          startDate: _startDate,
          endDate: _endDate,
          height: 70,
        ),
        Expanded(
          child: ListView(
            children: [
              TaskBox(VideoTask(
                Nof1Localizations.of(context).translate('video_task'),
                Nof1Localizations.of(context).translate('video_test'),
                'assets/rick-roll.mp4',
              )),
              // duplicate for testing purposes
              ...List.filled(
                  20,
                  TaskBox(PainRatingTask(
                    Nof1Localizations.of(context).translate('survey'),
                    Nof1Localizations.of(context).translate('survey_test'),
                  )))
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
