import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

import '../../../util/intervention.dart';

class InterventionCard extends StatelessWidget {
  final Intervention intervention;
  final bool selected;
  final bool showCheckbox;
  final bool showTasks;
  final Function() onTap;

  const InterventionCard(this.intervention,
      {this.onTap, this.selected = false, this.showCheckbox = true, this.showTasks = true, Key key})
      : super(key: key);
  String scheduleString(List<Schedule> schedules) {
    return schedules.map((schedule) {
      switch (schedule.runtimeType) {
        case FixedSchedule:
          final FixedSchedule fixedSchedule = schedule;
          return fixedSchedule.time.toString();

        default:
          print('Schedule not supported!');
          return '';
      }
    }).join(',');
  }

  List<Widget> _buildTaskList(ThemeData theme) => <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Daily Tasks:', style: theme.textTheme.bodyText2),
        ),
        Divider(
          height: 4,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: intervention.tasks
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: Text(task.title, style: theme.textTheme.bodyText2)),
                      FittedBox(
                          child: Text(
                        scheduleString(task.schedule),
                        style: theme.textTheme.bodyText2.copyWith(fontSize: 12, color: theme.textTheme.caption.color),
                      )),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isBaseline(intervention)) return BaselineCard();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(MdiIcons.fromString(intervention.icon)),
          trailing: showCheckbox
              ? Checkbox(
                  value: selected,
                  onChanged: (_) => onTap(), // Needed so Checkbox can be clicked and has color
                )
              : null,
          dense: true,
          title: Text(
            intervention.name,
            style: theme.textTheme.headline6,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            intervention.description ?? '',
            style: theme.textTheme.bodyText2.copyWith(color: theme.textTheme.caption.color),
          ),
        ),
        if (showTasks) ..._buildTaskList(theme)
      ],
    );
  }
}

class BaselineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(MdiIcons.rayStart),
          dense: true,
          title: Text(
            'Baseline',
            style: theme.textTheme.headline6,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            'A baseline study is an analysis of the current situation to identify the starting points for a programme or project. It looks at what information must be considered and analyzed to establish a baseline or starting point, the benchmark against which future progress can be assessed or comparisons made.',
            style: theme.textTheme.bodyText2.copyWith(color: theme.textTheme.caption.color),
          ),
        )
      ],
    );
  }
}
