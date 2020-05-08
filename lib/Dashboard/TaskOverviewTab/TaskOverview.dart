import 'package:app/Tasks/PainRaitingTask.dart';
import 'package:app/Tasks/VideoTask.dart';
import 'package:flutter/material.dart';

import 'CalendarRow.dart';
import 'TaskBox.dart';

class TaskOverview extends StatefulWidget {
  @override
  createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 6));
  DateTime _endDate = DateTime.now().add(Duration(days: 6));

  onSelect(data) {
    print("Selected Date -> $data");
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
