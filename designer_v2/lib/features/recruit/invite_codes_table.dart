import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_inline_menu.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/recruit/enrolled_badge.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

typedef ParticipantCountProvider = int Function(StudyInvite invite);

class StudyInvitesTable extends StatelessWidget {
  const StudyInvitesTable({
    required this.invites,
    required this.onSelect,
    required this.getInlineActions,
    required this.getActions,
    required this.getIntervention,
    required this.getParticipantCountForInvite,
    super.key,
  });

  final List<StudyInvite> invites;
  final OnSelectHandler<StudyInvite> onSelect;
  final ActionsProviderFor<StudyInvite> getActions;
  final ActionsProviderFor<StudyInvite> getInlineActions;

  final InterventionProvider getIntervention;
  final ParticipantCountProvider getParticipantCountForInvite;

  @override
  Widget build(BuildContext context) {
    return StandardTable<StudyInvite>(
      items: invites,
      columns: [
        StandardTableColumn(label: '#', columnWidth: const FixedColumnWidth(60)),
        StandardTableColumn(
            label: tr.code_list_header_code,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(200), FlexColumnWidth(1.6))),
        StandardTableColumn(
            label: tr.studies_list_header_participants_enrolled, columnWidth: const FixedColumnWidth(100)),
        StandardTableColumn(
            label: tr.form_field_preconfigured_schedule_intervention_a,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(150), FlexColumnWidth(1))),
        StandardTableColumn(
            label: tr.form_field_preconfigured_schedule_intervention_b,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(150), FlexColumnWidth(1))),
        //StandardTableColumn(label: '', columnWidth: const FixedColumnWidth(60)),
      ],
      onSelectItem: onSelect,
      buildCellsAt: _buildRow,
      trailingActionsAt: (item, _) => getActions(item),
      cellSpacing: 10.0,
      rowSpacing: 5.0,
      minRowHeight: 30.0,
    );
  }

  List<Widget> _buildRow(BuildContext context, StudyInvite item, int rowIdx, Set<MaterialState> states) {
    final theme = Theme.of(context);
    final mutedTextStyle = ThemeConfig.bodyTextBackground(theme);

    Intervention? interventionA;
    Intervention? interventionB;

    if (item.preselectedInterventionIds != null && item.preselectedInterventionIds!.isNotEmpty) {
      interventionA = getIntervention(item.preselectedInterventionIds![0]);
      interventionB = getIntervention(item.preselectedInterventionIds![1]);
    }

    Widget buildInterventionCell(Intervention? intervention) {
      return (intervention != null)
          ? Text(
              intervention.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            )
          : Text(
              tr.form_field_preconfigured_schedule_intervention_default,
              style: mutedTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            );
    }

    final participantCount = getParticipantCountForInvite(item);

    return [
      Text(rowIdx.toString(), style: mutedTextStyle),
      SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              item.code,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            // TODO: support inline actions in standard table widget
            ActionMenuInline(actions: getInlineActions(item))
          ],
        ),
      ),
      EnrolledBadge(enrolledCount: participantCount),
      buildInterventionCell(interventionA),
      buildInterventionCell(interventionB),
    ];
  }
}
