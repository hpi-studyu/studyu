import 'package:flutter/material.dart';

import '../../Tasks/pain_rating_task.dart';
import '../../Tasks/video_task.dart';
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
          'Video test',
          'This is a video test',
          'assets/rick-roll.mp4',
        )),
        TaskBox(PainRatingTask(
          'Survey test',
          'This is a survey test',
        )),
      ],
    );
  }
}
