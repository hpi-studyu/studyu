import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class StudyMonitorTable extends StatelessWidget {
  final List<StudyMonitorItem> studyMonitorItems;
  final OnSelectHandler<StudyMonitorItem> onSelectItem;

  const StudyMonitorTable({required this.studyMonitorItems, required this.onSelectItem, super.key});

  @override
  Widget build(BuildContext context) {
    return StandardTable<StudyMonitorItem>(
      items: studyMonitorItems,
      columns: [
        StandardTableColumn(
            label: tr.monitoring_table_column_participant_id,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(150), FlexColumnWidth(1.6))),
        StandardTableColumn(
            label: tr.monitoring_table_column_invite_code,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(200), FlexColumnWidth(1.6))),
        StandardTableColumn(
            sortable: true,
            label: tr.monitoring_table_column_enrolled,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(150), FlexColumnWidth(1.6))),
        StandardTableColumn(
            sortable: true,
            label: tr.monitoring_table_column_last_activity,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(150), FlexColumnWidth(1.6))),
        StandardTableColumn(
            sortable: true,
            label: tr.monitoring_table_column_day_in_study,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(125), FlexColumnWidth(1.6))),
        StandardTableColumn(
            sortable: true,
            label: tr.monitoring_table_column_completed_interventions,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(125), FlexColumnWidth(1.6))),
        StandardTableColumn(
            sortable: true,
            label: tr.monitoring_table_column_completed_surveys,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(125), FlexColumnWidth(1.6))),
      ],
      buildCellsAt: _buildRow,
      cellSpacing: 10.0,
      rowSpacing: 5.0,
      minRowHeight: 30.0,
      headerMaxLines: 2,
      onSelectItem: onSelectItem,
    );
  }

  List<Widget> _buildRow(BuildContext context, StudyMonitorItem item, int rowIdx, Set<MaterialState> states) {
    return [
      Tooltip(
        message: item.participantId,
        child: Text(item.participantId.split("-").first),
      ),
      Text(item.inviteCode ?? "-"),
      Tooltip(
        message: _formatTime(item.enrolledAt, true),
        child: Text(item.enrolledAt.toTimeAgoString()),
      ),
      Tooltip(
      message: _formatTime(item.lastActivityAt, true),
      child: Row(
        children: [
          Flexible(child: Text(item.lastActivityAt.toTimeAgoString())),
          if (item.droppedOut) 
             Row(
              children: [
                const SizedBox(width: 5.0),
                Tooltip(
                  message: tr.monitoring_table_row_tooltip_dropout,
                  child: const Icon(Icons.close, color: Colors.red, size: 16.0),
                ),
              ],
            ),
        ],
      ),
    ),
      _buildProgressCell(context, item.currentDayOfStudy, item.studyDurationInDays),
      _buildProgressCell(context, item.completedInterventions, item.completedInterventions + item.missedInterventions,tooltipMessage: tr.monitoring_table_completed_interventions_tooltip(
          item.completedInterventions,
          item.completedInterventions + item.missedInterventions,
        )),
      _buildProgressCell(context, item.completedSurveys, item.completedSurveys + item.missedSurveys),
    ];
  }

  String _formatTime(DateTime time, bool showTime) {
    final localTime = time.toLocal();
    final timeZoneOffsetInHours = localTime.timeZoneOffset.inHours;
    final timeZoneString = timeZoneOffsetInHours >= 0 ? "GMT +$timeZoneOffsetInHours" : "GMT $timeZoneOffsetInHours";
    final locale = tr.localeName == "de" ? "de_DE" : "en_US";
    final formattedDate = DateFormat("MMM d, yyyy", locale);
    if (!showTime) return formattedDate.format(localTime);
    final formattedTime = DateFormat.jm(locale);
    return "${formattedDate.format(localTime)}, ${formattedTime.format(localTime)} $timeZoneString";
  }

  Widget _buildProgressCell(BuildContext context, int progress, int total, {String tooltipMessage = ''} ) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        SizedBox.expand(
          child: LinearProgressIndicator(
            value: total <= 0 ? 0 : progress / total,
            backgroundColor: theme.primaryColor.withOpacity(0.7),
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$progress/$total",
                  style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4.0),
              if (tooltipMessage.isNotEmpty)
                Tooltip(
                  message: tooltipMessage,
                  child: const Icon(Icons.info_outline, color: Colors.white, size: 16.0),
                ),
            ],
          ),
          
        ),
      ],
    );
  }
}
