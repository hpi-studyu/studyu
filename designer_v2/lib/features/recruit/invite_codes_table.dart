import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_inline_menu.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/badge.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/recruit/enrolled_badge.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
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
    Key? key,
  }) : super(key: key);

  final List<StudyInvite> invites;
  final OnSelectHandler<StudyInvite> onSelect;
  final ActionsProviderFor<StudyInvite> getActions;
  final ActionsProviderFor<StudyInvite> getInlineActions;

  final InterventionProvider getIntervention;
  final ParticipantCountProvider getParticipantCountForInvite;

  static final List<StandardTableColumn> columns = [
    StandardTableColumn(
        label: '#'.hardcoded, columnWidth: const FixedColumnWidth(60)),
    StandardTableColumn(
        label: 'Code'.hardcoded,
        columnWidth:
            const MaxColumnWidth(FixedColumnWidth(200), FlexColumnWidth(1.6))),
    StandardTableColumn(
        label: 'Enrolled'.hardcoded, columnWidth: const FixedColumnWidth(100)),
    StandardTableColumn(
        label: 'Intervention A'.hardcoded,
        columnWidth:
            const MaxColumnWidth(FixedColumnWidth(150), FlexColumnWidth(1))),
    StandardTableColumn(
        label: 'Intervention B'.hardcoded,
        columnWidth:
            const MaxColumnWidth(FixedColumnWidth(150), FlexColumnWidth(1))),
    //StandardTableColumn(label: '', columnWidth: const FixedColumnWidth(60)),
  ];

  @override
  Widget build(BuildContext context) {
    return StandardTable<StudyInvite>(
      items: invites,
      columns: columns,
      onSelectItem: onSelect,
      buildCellsAt: _buildRow,
      trailingActionsAt: (item, _) => getActions(item),
      cellSpacing: 10.0,
      rowSpacing: 5.0,
      minRowHeight: 30.0,
    );
  }

  List<Widget> _buildRow(BuildContext context, StudyInvite item, int rowIdx,
      Set<MaterialState> states) {
    final theme = Theme.of(context);
    final mutedTextStyle = ThemeConfig.bodyTextBackground(theme);

    Intervention? interventionA;
    Intervention? interventionB;

    if (item.preselectedInterventionIds != null &&
        item.preselectedInterventionIds!.isNotEmpty) {
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
              'Default'.hardcoded,
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
