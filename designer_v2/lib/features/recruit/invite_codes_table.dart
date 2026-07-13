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

enum InviteCodesTableColumn {
  rowNumber,
  code,
  actions,
  enrolled,
  createdAt,
  updatedAt,
  interventionA,
  interventionB,
}

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final activeColumns = _visibleColumnsForWidth(constraints.maxWidth);
        final columns = [
          for (final column in activeColumns) _buildColumnDefinition(column),
        ];

        return StandardTable<StudyInvite>(
          items: invites,
          columns: columns,
          headerRowBuilder: (context, tableColumns) =>
              _buildHeaderRow(context, tableColumns, activeColumns),
          onSelectItem: onSelect,
          buildCellsAt: (context, item, rowIdx, states) =>
              _buildRow(context, item, rowIdx, states, activeColumns),
          trailingActionsAt: (item, _) => getActions(item),
          cellSpacing: 6.0,
          rowSpacing: 5.0,
          minRowHeight: 30.0,
        );
      },
    );
  }

  List<InviteCodesTableColumn> _visibleColumnsForWidth(double width) {
    final columns = [
      InviteCodesTableColumn.rowNumber,
      InviteCodesTableColumn.code,
      InviteCodesTableColumn.actions,
      InviteCodesTableColumn.enrolled,
      InviteCodesTableColumn.createdAt,
      InviteCodesTableColumn.updatedAt,
      InviteCodesTableColumn.interventionA,
      InviteCodesTableColumn.interventionB,
    ];

    if (width < 860) {
      columns.remove(InviteCodesTableColumn.interventionB);
    }
    if (width < 780) {
      columns.remove(InviteCodesTableColumn.interventionA);
    }
    if (width < 700) {
      columns.remove(InviteCodesTableColumn.updatedAt);
    }
    if (width < 620) {
      columns.remove(InviteCodesTableColumn.createdAt);
    }

    return columns;
  }

  StandardTableColumn _buildColumnDefinition(InviteCodesTableColumn column) {
    switch (column) {
      case InviteCodesTableColumn.rowNumber:
        return StandardTableColumn(
          label: '#',
          columnWidth: const FixedColumnWidth(48),
        );
      case InviteCodesTableColumn.code:
        return StandardTableColumn(
          label: tr.code_list_header_code,
          columnWidth: const MaxColumnWidth(
            FixedColumnWidth(140),
            FlexColumnWidth(),
          ),
          sortable: true,
        );
      case InviteCodesTableColumn.actions:
        return StandardTableColumn(
          label: '',
          columnWidth: const FixedColumnWidth(56),
        );
      case InviteCodesTableColumn.enrolled:
        return StandardTableColumn(
          label: tr.studies_list_header_participants_enrolled,
          columnWidth: const FixedColumnWidth(96),
          sortable: true,
        );
      case InviteCodesTableColumn.createdAt:
        return StandardTableColumn(
          label: tr.studies_list_header_created_at,
          columnWidth: const FixedColumnWidth(132),
          sortable: true,
        );
      case InviteCodesTableColumn.updatedAt:
        return StandardTableColumn(
          label: tr.code_list_header_updated_at,
          columnWidth: const FixedColumnWidth(132),
          sortable: true,
        );
      case InviteCodesTableColumn.interventionA:
        return StandardTableColumn(
          label: tr.form_field_preconfigured_schedule_intervention_a,
          columnWidth: const FixedColumnWidth(120),
        );
      case InviteCodesTableColumn.interventionB:
        return StandardTableColumn(
          label: tr.form_field_preconfigured_schedule_intervention_b,
          columnWidth: const FixedColumnWidth(120),
        );
    }
  }

  TableRow _buildHeaderRow(
    BuildContext context,
    List<StandardTableColumn> columns,
    List<InviteCodesTableColumn> activeColumns,
  ) {
    final headerWidgets = <Widget>[
      for (var i = 0; i < activeColumns.length; i++)
        _buildHeaderCell(
          context,
          activeColumns[i],
          columns[i],
          sortTarget: _sortTargetForColumn(activeColumns[i]),
        ),
      _buildHeaderCell(context, null, columns.last),
    ];

    return TableRow(children: headerWidgets);
  }

  InviteCodesSortColumn? _sortTargetForColumn(InviteCodesTableColumn column) {
    switch (column) {
      case InviteCodesTableColumn.code:
        return InviteCodesSortColumn.code;
      case InviteCodesTableColumn.enrolled:
        return InviteCodesSortColumn.enrolled;
      case InviteCodesTableColumn.createdAt:
        return InviteCodesSortColumn.createdAt;
      case InviteCodesTableColumn.updatedAt:
        return InviteCodesSortColumn.updatedAt;
      case InviteCodesTableColumn.rowNumber:
      case InviteCodesTableColumn.actions:
      case InviteCodesTableColumn.interventionA:
      case InviteCodesTableColumn.interventionB:
        return null;
    }
  }

  Widget _buildHeaderCell(
    BuildContext context,
    InviteCodesTableColumn? tableColumn,
    StandardTableColumn column, {
    InviteCodesSortColumn? sortTarget,
  }) {
    final isSortable = sortTarget != null;
    final isSortingActive = isSortable && sortColumn == sortTarget;
    final effectiveAscending = !isSortingActive || sortAscending;
    final padding = _headerPaddingForColumn(tableColumn);
    return Padding(
      padding: padding,
      child: StudiesTableColumnHeader(
        column.label,
        sortable: isSortable,
        sortingActive: isSortingActive,
        sortAscending: effectiveAscending,
        onSort: isSortable ? () => onSortColumn(sortTarget) : null,
        rightAlign: tableColumn == InviteCodesTableColumn.rowNumber,
      ),
    );
  }

  EdgeInsets _headerPaddingForColumn(InviteCodesTableColumn? column) {
    return switch (column) {
      InviteCodesTableColumn.rowNumber => const EdgeInsets.fromLTRB(
        6,
        10,
        4,
        10,
      ),
      InviteCodesTableColumn.code => const EdgeInsets.fromLTRB(8, 10, 8, 10),
      InviteCodesTableColumn.actions => const EdgeInsets.fromLTRB(2, 10, 2, 10),
      InviteCodesTableColumn.enrolled => const EdgeInsets.fromLTRB(
        8,
        10,
        8,
        10,
      ),
      InviteCodesTableColumn.createdAt ||
      InviteCodesTableColumn.updatedAt ||
      InviteCodesTableColumn.interventionA ||
      InviteCodesTableColumn.interventionB => const EdgeInsets.fromLTRB(
        8,
        10,
        8,
        10,
      ),
      null => const EdgeInsets.fromLTRB(4, 10, 4, 10),
    };
  }

  List<Widget> _buildRow(
    BuildContext context,
    StudyInvite item,
    int rowIdx,
    Set<WidgetState> states,
    List<InviteCodesTableColumn> activeColumns,
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

    Widget buildCell(InviteCodesTableColumn column) {
      switch (column) {
        case InviteCodesTableColumn.rowNumber:
          return Align(
            alignment: Alignment.centerRight,
            child: Text(
              (firstRowNumber + rowIdx).toString(),
              style: mutedTextStyle,
            ),
          );
        case InviteCodesTableColumn.code:
          return Text(item.code, maxLines: 1, overflow: TextOverflow.ellipsis);
        case InviteCodesTableColumn.actions:
          return Align(
            child: ActionMenuInline(
              actions: getInlineActions(item),
              iconSize: 18,
              splashRadius: 16,
              buttonConstraints: const BoxConstraints.tightFor(
                width: 24,
                height: 24,
              ),
              visualDensity: VisualDensity.compact,
              paddingHorizontal: 0,
            ),
          );
        case InviteCodesTableColumn.enrolled:
          return EnrolledBadge(enrolledCount: participantCount);
        case InviteCodesTableColumn.createdAt:
          return Text(createdAtText, style: mutedTextStyle);
        case InviteCodesTableColumn.updatedAt:
          return Text(updatedAtText, style: mutedTextStyle);
        case InviteCodesTableColumn.interventionA:
          return buildInterventionCell(interventionA);
        case InviteCodesTableColumn.interventionB:
          return buildInterventionCell(interventionB);
      }
    }

    return [for (final column in activeColumns) buildCell(column)];
  }
}
