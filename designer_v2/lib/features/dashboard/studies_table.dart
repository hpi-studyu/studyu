import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/features/study/study_participation_badge.dart';
import 'package:studyu_designer_v2/features/study/study_status_badge.dart';

class StudiesTable extends StatelessWidget {
  const StudiesTable({
    required this.studies,
    required this.onSelect,
    required this.getActions,
    required this.emptyWidget,
    Key? key,
  }) : super(key: key);

  final List<Study> studies;
  final OnSelectHandler<Study> onSelect;
  final ActionsProviderFor<Study> getActions;
  final Widget emptyWidget;

  @override
  Widget build(BuildContext context) {
    return StandardTable<Study>(
      items: studies,
      columns: [
        StandardTableColumn(
            label: tr.studies_list_header_title,
            columnWidth:
            const MaxColumnWidth(FixedColumnWidth(200), FlexColumnWidth(2.4))),
        StandardTableColumn(
            label: tr.studies_list_header_status,
            columnWidth:
            const MaxColumnWidth(FixedColumnWidth(90), IntrinsicColumnWidth())),
        StandardTableColumn(
            label: tr.studies_list_header_participation,
            columnWidth: const MaxColumnWidth(
                FixedColumnWidth(130), IntrinsicColumnWidth())),
        StandardTableColumn(
          label: tr.studies_list_header_created_at,
          columnWidth: const FlexColumnWidth(1),
        ),
        StandardTableColumn(
          label: tr.studies_list_header_participants_enrolled,
          columnWidth: const FlexColumnWidth(0.5),
        ),
        StandardTableColumn(
          label: tr.studies_list_header_participants_active,
          columnWidth: const FlexColumnWidth(0.5),
        ),
        StandardTableColumn(
          label: tr.studies_list_header_participants_completed,
          columnWidth: const FlexColumnWidth(0.5),
        ),
      ],
      onSelectItem: onSelect,
      trailingActionsAt: (item, _) => getActions(item),
      buildCellsAt: _buildRow,
      emptyWidget: emptyWidget,
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
