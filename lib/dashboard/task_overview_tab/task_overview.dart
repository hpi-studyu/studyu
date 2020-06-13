import 'package:flutter/material.dart';

import '../../tasks/pain_rating_task.dart';
import '../../tasks/video_task.dart';
import '../../util/localization.dart';
import '../dashboard.dart';
import 'progress_row.dart';
import 'task_box.dart';

class TaskOverview extends StatefulWidget {
  final List<PlannedIntervention> plannedInterventions;

  const TaskOverview({@required this.plannedInterventions, Key key}) : super(key: key);
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
                    style: theme.textTheme.subtitle2.copyWith(color: Colors.black)),
              ),
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
