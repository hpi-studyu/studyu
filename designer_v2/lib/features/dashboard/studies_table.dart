import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_participation_badge.dart';
import 'package:studyu_designer_v2/features/study/study_status_badge.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudiesTable extends StatelessWidget {
  const StudiesTable(
      {required this.studies,
      required this.onSelect,
      required this.getActions,
      Key? key})
      : super(key: key);

  final List<Study> studies;
  final OnSelectHandler<Study> onSelect;
  final ActionsProviderFor<Study> getActions;

  static final List<StandardTableColumn> columns = [
    StandardTableColumn(
        label: 'Title'.hardcoded,
        columnWidth:
            const MaxColumnWidth(FixedColumnWidth(200), FlexColumnWidth(2.5))),
    StandardTableColumn(
        label: 'Status'.hardcoded,
        columnWidth:
            const MaxColumnWidth(FixedColumnWidth(90), IntrinsicColumnWidth())),
    StandardTableColumn(
        label: 'Participation'.hardcoded,
        columnWidth:
            const MaxColumnWidth(FixedColumnWidth(120), IntrinsicColumnWidth())),
    StandardTableColumn(
      label: 'Created'.hardcoded,
      columnWidth: const FlexColumnWidth(1.3),
    ),
    StandardTableColumn(
      label: 'Enrolled'.hardcoded,
      columnWidth: const FlexColumnWidth(0.5),
    ),
    StandardTableColumn(
      label: 'Active'.hardcoded,
      columnWidth: const FlexColumnWidth(0.5),
    ),
    StandardTableColumn(
      label: 'Completed'.hardcoded,
      columnWidth: const FlexColumnWidth(0.5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StandardTable<Study>(
      items: studies,
      columns: columns,
      onSelectItem: onSelect,
      trailingActionsAt: (item, _) => getActions(item),
      buildCellsAt: _buildRow,
    );
  }

  List<Widget> _buildRow(
      BuildContext context, Study item, int rowIdx, Set<MaterialState> states) {
    final theme = Theme.of(context);

    TextStyle? mutedTextStyleIfZero(int value) {
      return (value > 0) ? null : ThemeConfig.bodyTextBackground(theme);
    }

    return [
      Text(item.title ?? '[Missing study title]'),
      StudyStatusBadge(
        status: item.status,
        showPrefixIcon: false,
        showTooltip: false,
      ),
      StudyParticipationBadge(
        participation: item.participation,
      ),
      Text(item.createdAt?.toTimeAgoString() ?? ''),
      Text(item.participantCount.toString(),
          style: mutedTextStyleIfZero(item.participantCount)),
      Text(item.activeSubjectCount.toString(),
          style: mutedTextStyleIfZero(item.activeSubjectCount)),
      Text(item.endedCount.toString(),
          style: mutedTextStyleIfZero(item.endedCount)),
    ];
  }
}
