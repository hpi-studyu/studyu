import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class ParticipantDetailsView extends ConsumerWidget {
  const ParticipantDetailsView({
    required this.monitorItem,
    required this.interventions,
    required this.observations,
    super.key,
  });

  final StudyMonitorItem monitorItem;
  final List<Intervention> interventions;
  final List<Observation> observations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantInfo(languageCode),
        const SizedBox(height: 8.0),
        const Divider(),
        Text(
          tr.participant_details_study_days_description,
          style: const TextStyle(fontSize: 16.0, color: Colors.black54),
        ),
        const SizedBox(height: 16.0),
        _buildPerDayStatus(),
        const SizedBox(height: 16.0),
        _buildColorLegend(),
      ],
    );
  }

  Widget _buildParticipantInfo(String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          tr.monitoring_table_column_participant_id,
          monitorItem.participantId,
        ),
        _buildInfoRow(
          tr.monitoring_table_column_invite_code,
          monitorItem.inviteCode ?? '-',
        ),
        _buildInfoRow(
          tr.monitoring_table_column_enrolled,
          monitorItem.startedAt
              .toLocalizedString(locale: languageCode, showTime: false),
        ),
        _buildInfoRow(
          tr.monitoring_table_column_last_activity,
          monitorItem.lastActivityAt.toLocalizedString(locale: languageCode),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildPerDayStatus() {
    final studySchedule = StudySchedule();
    final int totalCompletedDays = monitorItem.missedTasksPerDay.length;

    final phases = <StudyPhase>[];

    if (studySchedule.includeBaseline) {
      phases.add(StudyPhase(
          name: 'Baseline',
          missedTasksPerDay: monitorItem.missedTasksPerDay.sublist(
              0,
              totalCompletedDays > studySchedule.baselineLength
                  ? studySchedule.baselineLength
                  : totalCompletedDays)));
    }

    final String sequence = studySchedule.nameOfSequence;

    for (var i = 0; i < studySchedule.numberOfCycles * 2; i++) {
      final int phaseDuration = studySchedule.phaseDuration;
      final bool includeBaseline = studySchedule.includeBaseline;
      final int baselineAdjustmentStart =
          includeBaseline ? (i + 1) * phaseDuration : i * phaseDuration;
      final int baselineAdjustmentEnd =
          includeBaseline ? (i + 2) * phaseDuration : (i + 1) * phaseDuration;

      if (baselineAdjustmentStart >= totalCompletedDays) break;

      final int start = totalCompletedDays > baselineAdjustmentStart
          ? baselineAdjustmentStart
          : totalCompletedDays;

      final int end = totalCompletedDays > baselineAdjustmentEnd
          ? baselineAdjustmentEnd
          : totalCompletedDays;

      final String interventionName =
          sequence[i] == "A" ? interventions[0].name! : interventions[1].name!;

      phases.add(StudyPhase(
          name: interventionName,
          missedTasksPerDay:
              monitorItem.missedTasksPerDay.sublist(start, end)));
    }

    assert(
      monitorItem.missedTasksPerDay.length ==
          monitorItem.completedTasksPerDay.length,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: phases.mapIndexed((phaseIndex, phase) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phase.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              children: phase.missedTasksPerDay
                  .mapIndexed((index, missed) => _buildSquare(index, missed,
                      (phaseIndex * studySchedule.phaseDuration) + index + 1))
                  .toList(),
            ),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSquare(int index, Set<String> missed, int numberOfTheDay) {
    return Tooltip(
      message: _getTooltipText(
        missed,
        monitorItem.completedTasksPerDay[index],
      ),
      child: Container(
        height: 50,
        width: 50,
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 8),
        decoration: BoxDecoration(
          color: missed.isEmpty
              ? Colors.green
              : (monitorItem.completedTasksPerDay[index].isEmpty
                  ? Colors.red
                  : Colors.orange),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            numberOfTheDay.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _getTooltipText(
    Set<String> missedTaskIds,
    Set<String> completedTaskIds,
  ) {
    final sb = StringBuffer();
    for (final intervention in interventions) {
      for (final task in intervention.tasks) {
        if (missedTaskIds.contains(task.id)) {
          sb.writeln('\u{274C} ${intervention.name} - ${task.title}');
        } else if (completedTaskIds.contains(task.id)) {
          sb.writeln('\u{2705} ${intervention.name} - ${task.title}');
        }
      }
    }
    for (final observation in observations) {
      if (missedTaskIds.contains(observation.id)) {
        sb.writeln('\u{274C} ${observation.title}');
      } else if (completedTaskIds.contains(observation.id)) {
        sb.writeln('\u{2705} ${observation.title}');
      }
    }
    return sb.toString();
  }

  Widget _buildColorLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.participant_details_color_legend_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            _buildLegendItem(
              Colors.green,
              tr.participant_details_color_legend_completed,
            ),
            const SizedBox(width: 16.0),
            _buildLegendItem(
              Colors.orange,
              tr.participant_details_color_legend_partially_completed,
            ),
            const SizedBox(width: 16.0),
            _buildLegendItem(
              Colors.red,
              tr.participant_details_color_legend_missed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: color,
          ),
        ),
        const SizedBox(width: 8.0),
        Text(text),
      ],
    );
  }
}

class StudyPhase {
  final String name;
  final List<Set<String>> missedTasksPerDay;

  StudyPhase({required this.name, required this.missedTasksPerDay});
}
