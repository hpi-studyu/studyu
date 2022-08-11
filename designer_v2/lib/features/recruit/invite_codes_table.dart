import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_inline_menu.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudyInvitesTable extends StatelessWidget {
  const StudyInvitesTable({
    required this.invites,
    required this.onSelectInvite,
    required this.getIntervention,
    required this.getInlineActionsForInvite,
    required this.getActionsForInvite,
    Key? key
  }) : super(key: key);

  final List<StudyInvite> invites;
  final OnSelectHandler<StudyInvite> onSelectInvite;
  final InterventionProvider getIntervention;
  final ActionsProviderFor<StudyInvite> getActionsForInvite;
  final ActionsProviderFor<StudyInvite> getInlineActionsForInvite;

  static final List<StandardTableColumn> columns = [
    StandardTableColumn(
        label: '#'.hardcoded,
        columnWidth: const FixedColumnWidth(60)),
    StandardTableColumn(
        label: 'Code'.hardcoded,
        columnWidth: const MaxColumnWidth(
            FixedColumnWidth(200), FlexColumnWidth(1.6))),
    StandardTableColumn(
        label: 'Enrolled'.hardcoded,
        columnWidth: const FixedColumnWidth(100)),
    StandardTableColumn(
        label: 'Intervention A'.hardcoded,
        columnWidth: const MaxColumnWidth(
            FixedColumnWidth(150), FlexColumnWidth(1))),
    StandardTableColumn(
        label: 'Intervention B'.hardcoded,
        columnWidth: const MaxColumnWidth(
            FixedColumnWidth(150), FlexColumnWidth(1))),
    StandardTableColumn(
        label: '',
        columnWidth: const FixedColumnWidth(60)
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StandardTable<StudyInvite>(
        items: invites,
        columns: columns,
        onSelectItem: onSelectInvite,
        buildCellsAt: _buildRow,
        cellSpacing: 10.0,
        rowSpacing: 5.0,
        minRowHeight: 30.0,
    );
  }

  List<Widget> _buildRow(
      BuildContext context,
      StudyInvite item,
      int rowIdx,
      Set<MaterialState> states
  ) {
    final theme = Theme.of(context);
    final tableTextStylePrimary = theme.textTheme.bodyText1;
    final tableTextSecondaryColor = theme.colorScheme.secondary;
    final tableTextStyleSecondary = tableTextStylePrimary!.copyWith(
        color: tableTextSecondaryColor);
    final tableTextStyleTertiary = tableTextStylePrimary.copyWith(
        color: tableTextSecondaryColor.withOpacity(0.5));

    Intervention? interventionA;
    Intervention? interventionB;

    if (item.preselectedInterventionIds != null
        && item.preselectedInterventionIds!.isNotEmpty) {
      interventionA = getIntervention(item.preselectedInterventionIds![0]);
      interventionB = getIntervention(item.preselectedInterventionIds![1]);
    }

    Widget buildInterventionCell(Intervention? intervention) {
      return (intervention != null) ?
        Text(
          intervention.name ?? '',
          style: tableTextStyleSecondary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ) : Text(
          'Default'.hardcoded,
          style: tableTextStyleTertiary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        );
    }

    return [
      Text(rowIdx.toString(), style: tableTextStyleTertiary),
      SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              item.code,
              style: tableTextStyleSecondary.copyWith(
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            ActionMenuInline(actions: getInlineActionsForInvite(item))
          ],
        ),
      ),
      Text('[TODO]', style: tableTextStyleSecondary), // TODO
      buildInterventionCell(interventionA),
      buildInterventionCell(interventionB),
      Align(
        alignment: Alignment.centerRight,
        child: ActionPopUpMenuButton(
          actions: getActionsForInvite(item),
          orientation: Axis.horizontal,
          triggerIconColor: tableTextSecondaryColor.withOpacity(0.8),
          triggerIconColorHover: theme.colorScheme.primary,
          disableSplashEffect: true,
          position: PopupMenuPosition.over,
        ),
      )
    ];
  }
}
