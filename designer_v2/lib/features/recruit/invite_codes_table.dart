import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_inline_menu.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table_column_header.dart';
import 'package:studyu_designer_v2/features/recruit/enrolled_badge.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

typedef ParticipantCountProvider = int Function(StudyInvite invite);

class StudyInvitesTable extends StatelessWidget {
  const StudyInvitesTable({
    required this.invites,
    required this.onSelect,
    required this.getInlineActions,
    required this.getActions,
    required this.getIntervention,
    required this.getParticipantCountForInvite,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSortColumn,
    this.firstRowNumber = 1,
    super.key,
  });

  final List<StudyInvite> invites;
  final OnSelectHandler<StudyInvite> onSelect;
  final ActionsProviderFor<StudyInvite> getActions;
  final ActionsProviderFor<StudyInvite> getInlineActions;

  final InterventionProvider getIntervention;
  final ParticipantCountProvider getParticipantCountForInvite;
  final InviteCodesSortColumn sortColumn;
  final bool sortAscending;
  final void Function(InviteCodesSortColumn column) onSortColumn;
  final int firstRowNumber;

  @override
  Widget build(BuildContext context) {
    return StandardTable<StudyInvite>(
      items: invites,
      columns: [
        StandardTableColumn(
          label: '#',
          columnWidth: const FixedColumnWidth(60),
        ),
        StandardTableColumn(
          label: tr.code_list_header_code,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(200),
            FlexColumnWidth(1.6),
          ),
          sortable: true,
        ),
        StandardTableColumn(
          label: tr.studies_list_header_participants_enrolled,
          columnWidth: const FixedColumnWidth(100),
        ),
        StandardTableColumn(
          label: tr.studies_list_header_created_at,
          columnWidth: const FixedColumnWidth(120),
          sortable: true,
        ),
        StandardTableColumn(
          label: tr.code_list_header_updated_at,
          columnWidth: const FixedColumnWidth(120),
          sortable: true,
        ),
        StandardTableColumn(
          label: tr.form_field_preconfigured_schedule_intervention_a,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(150),
            FlexColumnWidth(),
          ),
        ),
        StandardTableColumn(
          label: tr.form_field_preconfigured_schedule_intervention_b,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(150),
            FlexColumnWidth(),
          ),
        ),
        //StandardTableColumn(label: '', columnWidth: const FixedColumnWidth(60)),
      ],
      headerRowBuilder: _buildHeaderRow,
      onSelectItem: onSelect,
      buildCellsAt: _buildRow,
      trailingActionsAt: (item, _) => getActions(item),
      rowSpacing: 5.0,
      minRowHeight: 30.0,
    );
  }

  TableRow _buildHeaderRow(
    BuildContext context,
    List<StandardTableColumn> columns,
  ) {
    final headerWidgets = <Widget>[
      _buildHeaderCell(context, columns[0]),
      _buildHeaderCell(
        context,
        columns[1],
        sortTarget: InviteCodesSortColumn.code,
      ),
      _buildHeaderCell(context, columns[2]),
      _buildHeaderCell(
        context,
        columns[3],
        sortTarget: InviteCodesSortColumn.createdAt,
      ),
      _buildHeaderCell(
        context,
        columns[4],
        sortTarget: InviteCodesSortColumn.updatedAt,
      ),
      _buildHeaderCell(context, columns[5]),
      _buildHeaderCell(context, columns[6]),
      _buildHeaderCell(context, columns[7]),
    ];

    return TableRow(children: headerWidgets);
  }

  Widget _buildHeaderCell(
    BuildContext context,
    StandardTableColumn column, {
    InviteCodesSortColumn? sortTarget,
  }) {
    final isSortable = sortTarget != null;
    final isSortingActive = isSortable && sortColumn == sortTarget;
    final effectiveAscending = !isSortingActive || sortAscending;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: StudiesTableColumnHeader(
        column.label,
        sortable: isSortable,
        sortingActive: isSortingActive,
        sortAscending: effectiveAscending,
        onSort: isSortable ? () => onSortColumn(sortTarget) : null,
      ),
    );
  }

  List<Widget> _buildRow(
    BuildContext context,
    StudyInvite item,
    int rowIdx,
    Set<WidgetState> states,
  ) {
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
              tr.form_field_preconfigured_schedule_intervention_default,
              style: mutedTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            );
    }

    final participantCount = getParticipantCountForInvite(item);
    final createdAtText = item.createdAt?.toTimeAgoString() ?? '-';
    final updatedAtText = item.updatedAt?.toTimeAgoString() ?? '-';

    return [
      Text((firstRowNumber + rowIdx).toString(), style: mutedTextStyle),
      SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              item.code,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
            // TODO: support inline actions in standard table widget
            ActionMenuInline(actions: getInlineActions(item)),
          ],
        ),
      ),
      EnrolledBadge(enrolledCount: participantCount),
      Text(createdAtText, style: mutedTextStyle),
      Text(updatedAtText, style: mutedTextStyle),
      buildInterventionCell(interventionA),
      buildInterventionCell(interventionB),
    ];
  }
}
