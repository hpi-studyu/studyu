import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_core/core.dart';

class InterventionCard extends StatelessWidget {
  final Intervention intervention;
  final bool selected;
  final bool showCheckbox;
  final bool showTasks;
  final bool showDescription;
  final Function()? onTap;

  const InterventionCard(
    this.intervention, {
    this.onTap,
    this.selected = false,
    this.showCheckbox = false,
    this.showTasks = true,
    this.showDescription = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InterventionCardTitle(
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

class InterventionCardTitle extends StatelessWidget {
  final Intervention? intervention;
  final bool selected;
  final bool showCheckbox;
  final bool showDescriptionButton;
  final Function()? onTap;

  const InterventionCardTitle({
    required this.intervention,
    this.selected = false,
    this.showCheckbox = false,
    this.showDescriptionButton = true,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(MdiIcons.fromString(intervention!.icon), color: theme.colorScheme.secondary),
      trailing: showCheckbox
          ? Checkbox(
              value: selected,
              onChanged: (_) => onTap!(), // Needed so Checkbox can be clicked and has color
            )
          : null,
      dense: true,
      title: Row(
        children: [
          Expanded(child: Text(intervention!.name!, style: theme.textTheme.titleLarge)),
          if (showDescriptionButton)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  final description = intervention!.isBaseline()
                      ? AppLocalizations.of(context)!.baseline_description
                      : intervention!.description;
                  return AlertDialog(
                    title: ListTile(
                      leading: Icon(MdiIcons.fromString(intervention!.icon), color: theme.colorScheme.secondary),
                      dense: true,
                      title: Text(intervention!.name!, style: theme.textTheme.titleLarge),
                    ),
                    content: HtmlText(description),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class InterventionCardDescription extends StatelessWidget {
  final Intervention intervention;

  const InterventionCardDescription({required this.intervention, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final description =
        intervention.isBaseline() ? AppLocalizations.of(context)!.baseline_description : intervention.description;
    if (description == null) return Container();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        description,
        style: theme.textTheme.bodyMedium!.copyWith(color: theme.textTheme.bodySmall!.color),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<InterventionTask> tasks;

  const _TaskList({required this.tasks});

  String scheduleString(List<CompletionPeriod> schedules) {
    return schedules
        .map((completionPeriod) => '${completionPeriod.unlockTime} - ${completionPeriod.lockTime}')
        .join(',');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.tasks_daily, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        const Divider(
          height: 4,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: tasks
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(task.title!, style: theme.textTheme.bodyMedium)),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: theme.textTheme.bodySmall!.color),
                          const SizedBox(width: 4),
                          Text(
                            scheduleString(task.schedule.completionPeriods),
                            style: theme.textTheme.bodyMedium!
                                .copyWith(fontSize: 12, color: theme.textTheme.bodySmall!.color),
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
