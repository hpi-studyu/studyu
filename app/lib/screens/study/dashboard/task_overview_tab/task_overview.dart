import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quiver/collection.dart';
import 'package:studyou_core/models/models.dart';

import '../../../../util/localization.dart';
import '../../onboarding/intervention_card.dart';
import 'progress_row.dart';
import 'task_box.dart';

class TaskOverview extends StatefulWidget {
  final ParseUserStudy study;
  final Multimap<Time, Task> scheduleToday;
  final String interventionIcon;

  const TaskOverview({@required this.study, @required this.scheduleToday, Key key, this.interventionIcon})
      : super(key: key);
  @override
  _TaskOverviewState createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview> {
  List<Widget> buildScheduleToday(BuildContext context) {
    final theme = Theme.of(context);

    return widget.scheduleToday.keys
        .expand((time) => [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: theme.primaryColor),
                    SizedBox(width: 8),
                    Text(time.toString(),
                        style: theme.textTheme.subtitle2.copyWith(fontSize: 16, color: theme.primaryColor)),
                  ],
                ),
              ),
              ...widget.scheduleToday[time].map((task) => TaskBox(
                  task: task,
                  icon: Icon(task is Observation
                      ? MdiIcons.orderBoolAscendingVariant
                      : MdiIcons.fromString(widget.interventionIcon))))
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
              InterventionCard(widget.study.getInterventionForDate(DateTime.now()),
                  showCheckbox: false, showTasks: false),
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
