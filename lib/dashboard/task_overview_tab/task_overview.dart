import 'package:flutter/material.dart';

import '../../tasks/pain_rating_task.dart';
import '../../tasks/video_task.dart';
import '../../util/localization.dart';
import 'calendar_row.dart';
import 'task_box.dart';

class TaskOverview extends StatefulWidget {
  @override
  _TaskOverviewState createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview> {
  final DateTime _startDate = DateTime.now().subtract(Duration(days: 6));
  final DateTime _endDate = DateTime.now().add(Duration(days: 6));

  void onSelect(DateTime date) {
    print("Selected Date -> $date");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CalendarRow(
          startDate: _startDate,
          endDate: _endDate,
          onDatePressed: onSelect,
          itemsAtOnce: 8,
        ),
        TaskBox(VideoTask(
          Nof1Localizations.of(context).translate("video_task"),
          Nof1Localizations.of(context).translate("video_test"),
          'assets/rick-roll.mp4',
        )),
        TaskBox(PainRatingTask(
          Nof1Localizations.of(context).translate("survey"),
          Nof1Localizations.of(context).translate("survey_test"),
        )),
      ],
    );
  }
}
