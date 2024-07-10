import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class ParticipantDetailsView extends ConsumerWidget {
  const ParticipantDetailsView({
    required this.monitorItem,
    required this.interventions,
    required this.observations,
    required this.studySchedule,
    super.key,
  });

  final StudyMonitorItem monitorItem;
  final List<Intervention> interventions;
  final List<Observation> observations;
  final StudySchedule studySchedule;

  static const Color incompleteColor = Color.fromARGB(255, 234, 234, 234);
  // Add transparency to increase the readability of the text
  static Color partiallyComplete = Colors.lightBlue.faded(0.75);
  static const Color completeColor = Colors.lightBlue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantInfo(languageCode),
        const SizedBox(height: 8.0),
        const Divider(),
        const SizedBox(height: 8.0),
        if (monitorItem.missedTasksPerDay.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextParagraph(
                text: tr.participant_details_study_days_description,
              ),
              const SizedBox(height: 16.0),
              _buildPerDayStatus(),
              const SizedBox(height: 16.0),
              _buildColorLegend(),
            ],
          )
        else
          EmptyBody(
            icon: Icons.hourglass_empty,
            title: tr.participant_details_progress_empty_title,
            description: tr.participant_details_progress_empty_description,
          ),
      ],
    );
  }

  Widget _buildParticipantInfo(String languageCode) {
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            tr.monitoring_table_column_participant_id,
            monitorItem.participantId,
          ),
          _buildInfoRow(
            tr.monitoring_table_column_invite_code,
            monitorItem.inviteCode ?? 'N/A',
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
      ),
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
    final int totalCompletedDays = monitorItem.missedTasksPerDay.length;

    final phases = <StudyPhase>[];

    if (studySchedule.includeBaseline) {
      phases.add(
        StudyPhase(
          name: 'Baseline',
          missedTasksPerDay: monitorItem.missedTasksPerDay.sublist(
            0,
            totalCompletedDays > studySchedule.baselineLength
                ? studySchedule.baselineLength
                : totalCompletedDays,
          ),
        ),
      );
    }

    final String sequence = studySchedule.nameOfSequence;

    for (int i = 0; i < studySchedule.numberOfCycles * 2; i++) {
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

      var sequenceIndex = i;
      if (sequenceIndex > 3) sequenceIndex = i % 4;

      final String interventionName = sequence[sequenceIndex] == "A"
          ? interventions[0].name!
          : interventions[1].name!;

      phases.add(
        StudyPhase(
          name: interventionName,
          missedTasksPerDay: monitorItem.missedTasksPerDay.sublist(start, end),
        ),
      );
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
            const SizedBox(height: 10),
            Wrap(
              children: phase.missedTasksPerDay
                  .mapIndexed(
                    (index, missed) => _buildSquare(
                      index,
                      missed,
                      (phaseIndex * studySchedule.phaseDuration) + index + 1,
                    ),
                  )
                  .toList(),
            ),
            if (phaseIndex < phases.length - 1) const SizedBox(height: 10),
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
              ? completeColor
              : (monitorItem.completedTasksPerDay[index].isEmpty
                  ? incompleteColor
                  : null), // Set color to null when using gradient
          gradient:
              monitorItem.completedTasksPerDay[index].isEmpty || missed.isEmpty
                  ? null
                  : _buildGradient(),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            numberOfTheDay.toString(),
            style: TextStyle(
              color: missed.isEmpty ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
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
        sb.write('\u{274C} ${observation.title}');
      } else if (completedTaskIds.contains(observation.id)) {
        sb.write('\u{2705} ${observation.title}');
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildLegendItem(
                  color: completeColor,
                  tr.participant_details_color_legend_completed,
                  tr.participant_details_completed_legend_tooltip,
                ),
                const SizedBox(width: 16.0),
                _buildLegendItem(
                  color: partiallyComplete,
                  tr.participant_details_color_legend_partially_completed,
                  tr.participant_details_partially_completed_legend_tooltip,
                  gradient: true,
                ),
                const SizedBox(width: 16.0),
                _buildLegendItem(
                  color: incompleteColor,
                  tr.participant_details_color_legend_missed,
                  tr.participant_details_incomplete_legend_tooltip,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                _buildLegendItem(
                  widget: const Text('\u{2705}'),
                  tr.participant_details_color_legend_completed_task,
                  tr.participant_details_color_legend_completed_task_tooltip,
                ),
                const SizedBox(width: 16.0),
                _buildLegendItem(
                  widget: const Text('\u{274C}'),
                  tr.participant_details_color_legend_missed_task,
                  tr.participant_details_color_legend_missed_task_tooltip,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String text,
    String tooltipMessage, {
    Color? color,
    Widget? widget,
    bool gradient = false,
  }) {
    if (color == null && widget == null) {
      throw ArgumentError('Only color or widget can be provided.');
    }
    return Tooltip(
      message: tooltipMessage,
      child: Row(
        children: [
          if (color != null)
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color,
                gradient: gradient ? _buildGradient() : null,
              ),
            ),
          if (widget != null) widget,
          const SizedBox(width: 8.0),
          Text(text),
        ],
      ),
    );
  }

  LinearGradient _buildGradient() {
    return LinearGradient(
      begin: Alignment.topRight,
      end: const Alignment(0.5, -0.4),
      stops: const [0.0, 0.5, 0.5, 1],
      colors: [
        partiallyComplete,
        partiallyComplete,
        incompleteColor,
        incompleteColor,
      ],
      tileMode: TileMode.repeated,
    );
  }
}

class StudyPhase {
  final String name;
  final List<Set<String>> missedTasksPerDay;

  StudyPhase({required this.name, required this.missedTasksPerDay});
}
