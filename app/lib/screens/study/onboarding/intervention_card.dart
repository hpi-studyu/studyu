import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

import '../../../util/intervention.dart';
import '../../../util/localization.dart';

// TODO: Make sure those props are set in the model by default
Intervention addBaselineProps(Intervention intervention) => intervention
  ..icon = 'rayStart'
  ..description = '''
A baseline study is an analysis of the current situation to identify the starting points for a programme or project. 
It looks at what information must be considered and analyzed to establish a baseline or starting point, 
the benchmark against which future progress can be assessed or comparisons made.
''';

class InterventionCard extends StatelessWidget {
  final Intervention intervention;
  final bool selected;
  final bool showCheckbox;
  final bool showTasks;
  final bool showDescription;
  final Function() onTap;

  InterventionCard(Intervention intervention,
      {this.onTap,
      this.selected = false,
      this.showCheckbox = false,
      this.showTasks = true,
      this.showDescription = true,
      Key key})
      : intervention = isBaseline(intervention) ? addBaselineProps(intervention) : intervention,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InterventionCardTitleTile(
          intervention: intervention,
          showCheckbox: showCheckbox,
          showDescriptionButton: !showDescription,
          onTap: onTap,
          selected: selected,
        ),
        if (showDescription) InterventionCardDescription(intervention: intervention),
        if (showTasks && intervention.tasks.isNotEmpty) _TaskList(tasks: intervention.tasks)
      ],
    );
  }
}

class InterventionCardTitleTile extends StatelessWidget {
  final Intervention intervention;
  final bool selected;
  final bool showCheckbox;
  final bool showDescriptionButton;
  final Function() onTap;

  InterventionCardTitleTile({
    @required Intervention intervention,
    this.selected = false,
    this.showCheckbox = false,
    this.showDescriptionButton = true,
    this.onTap,
    Key key,
  })  : intervention = isBaseline(intervention) ? addBaselineProps(intervention) : intervention,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(MdiIcons.fromString(intervention.icon), color: theme.accentColor),
      trailing: showCheckbox
          ? Checkbox(
              value: selected,
              onChanged: (_) => onTap(), // Needed so Checkbox can be clicked and has color
            )
          : null,
      dense: true,
      title: Row(
        children: [
          Text(intervention.name, style: theme.textTheme.headline6),
          if (showDescriptionButton)
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: ListTile(
                      leading: Icon(MdiIcons.fromString(intervention.icon), color: theme.accentColor),
                      dense: true,
                      title: Text(intervention.name, style: theme.textTheme.headline6)),
                  content: Text(intervention.description ?? ''),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class InterventionCardDescription extends StatelessWidget {
  final Intervention intervention;

  InterventionCardDescription({@required Intervention intervention, Key key})
      : intervention = isBaseline(intervention) ? addBaselineProps(intervention) : intervention,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        intervention.description ?? '',
        style: theme.textTheme.bodyText2.copyWith(color: theme.textTheme.caption.color),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<InterventionTask> tasks;

  const _TaskList({@required this.tasks, Key key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Nof1Localizations.of(context).translate('tasks_daily'), style: theme.textTheme.bodyText2),
            ],
          ),
        ),
        Divider(
          height: 4,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: tasks
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: Text(task.title, style: theme.textTheme.bodyText2)),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: theme.textTheme.caption.color),
                          SizedBox(width: 4),
                          Text(
                            scheduleString(task.schedule),
                            style:
                                theme.textTheme.bodyText2.copyWith(fontSize: 12, color: theme.textTheme.caption.color),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
