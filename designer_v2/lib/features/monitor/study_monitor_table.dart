import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyMonitorItem extends Equatable {
  final String participantId;
  final String? inviteCode;
  final DateTime enrolledAt;
  final DateTime lastActivityAt;
  final int currentDayOfStudy;
  final int studyDurationInDays;
  final int completedInterventions;
  final int missedInterventions;
  final int completedSurveys;
  final int missedSurveys;
  final String rawData;

  const StudyMonitorItem({
    required this.participantId,
    required this.inviteCode,
    required this.enrolledAt,
    required this.lastActivityAt,
    required this.currentDayOfStudy,
    required this.studyDurationInDays,
    required this.completedInterventions,
    required this.missedInterventions,
    required this.completedSurveys,
    required this.missedSurveys,
    required this.rawData,
  });

  static List<StudyMonitorItem> fromStudy(Study study) {
    final List<StudyMonitorItem> items = [];

    final participants = study.participants ?? [];
    final participantsProgress = study.participantsProgress ?? [];

    participants.sort((a, b) => a.startedAt!.compareTo(b.startedAt!)); // ascending

    for (final participant in participants) {
      final progresses = participantsProgress.where((progress) => progress.subjectId == participant.id).toList();
      progresses.sort((b, a) => a.completedAt!.compareTo(b.completedAt!)); // descending
      final interventionOrder = study.schedule.generateInterventionIdsInOrder(participant.selectedInterventionIds);
      final lastActivityAt = progresses.isNotEmpty ? progresses.first.completedAt! : participant.startedAt!;
      final studyDurationInDays = study.schedule.length;
      final currentDayOfStudy =
          min(studyDurationInDays, DateTime.now().toUtc().difference(participant.startedAt!).inDays);
      final daysInBaseline = study.schedule.includeBaseline ? study.schedule.phaseDuration : 0;

      int totalInterventions = 0;
      for (int day = 0; day < currentDayOfStudy; day++) {
        if (day < daysInBaseline) {
          continue;
        }

        final interventionIdForThisPhase = interventionOrder[day ~/ study.schedule.phaseDuration];
        final interventionForThisPhase = study.interventions.firstWhere((i) => i.id == interventionIdForThisPhase);
        totalInterventions += interventionForThisPhase.tasks.length;
      }

      final totalSurveys = currentDayOfStudy * study.observations.length;

      final completedInterventions = progresses.where((p) => p.resultType == "bool").toList();
      final completedSurveys = progresses.where((p) => p.resultType != "bool").toList();

      final missedInterventions = totalInterventions - completedInterventions.length;
      final missedSurveys = totalSurveys - completedSurveys.length;

      final rawDataDict = {
        "participant": participant.toJson(),
        "interventions": completedInterventions.map((p) => p.toJson()).toList(),
        "surveys": completedSurveys.map((p) => p.toJson()).toList(),
      };

      final rawData = const JsonEncoder.withIndent('    ').convert(rawDataDict);

      items.add(StudyMonitorItem(
        participantId: participant.id,
        inviteCode: participant.inviteCode,
        enrolledAt: participant.startedAt!,
        lastActivityAt: lastActivityAt,
        currentDayOfStudy: currentDayOfStudy,
        studyDurationInDays: studyDurationInDays,
        completedInterventions: completedInterventions.length,
        missedInterventions: missedInterventions,
        completedSurveys: completedSurveys.length,
        missedSurveys: missedSurveys,
        rawData: rawData,
      ));
    }

    return items;
  }

  @override
  List<Object?> get props => [participantId];
}

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
            label: tr.monitoring_table_column_enrolled,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(150), FlexColumnWidth(1.6))),
        StandardTableColumn(
            label: tr.monitoring_table_column_last_activity,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(150), FlexColumnWidth(1.6))),
        StandardTableColumn(
            label: tr.monitoring_table_column_day_in_study,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(125), FlexColumnWidth(1.6))),
        StandardTableColumn(
            label: tr.monitoring_table_column_completed_interventions,
            columnWidth: const MaxColumnWidth(FixedColumnWidth(125), FlexColumnWidth(1.6))),
        StandardTableColumn(
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
        child: Text(_formatTime(item.enrolledAt, false)),
      ),
      Tooltip(
        message: _formatTime(item.lastActivityAt, true),
        child: Text(_formatTime(item.lastActivityAt, false)),
      ),
      _buildProgressCell(context, item.currentDayOfStudy, item.studyDurationInDays),
      _buildProgressCell(context, item.completedInterventions, item.completedInterventions + item.missedInterventions),
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

  Widget _buildProgressCell(BuildContext context, int progress, int total) {
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
          child: Text("$progress/$total",
              style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
