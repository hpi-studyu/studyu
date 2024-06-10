import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class ParticipantDetailsView extends ConsumerWidget {
  const ParticipantDetailsView(
      {required this.monitorItem,
      required this.interventions,
      required this.observations,
      super.key});

  final StudyMonitorItem monitorItem;
  final List<Intervention> interventions;
  final List<Observation> observations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.participant_details_study_days_overview,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8.0),
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
        _buildInfoRow(tr.monitoring_table_column_participant_id,
            monitorItem.participantId),
        _buildInfoRow(tr.monitoring_table_column_invite_code,
            monitorItem.inviteCode ?? '-'),
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
    assert(monitorItem.missedTasksPerDay.length ==
        monitorItem.completedTasksPerDay.length);
    return Wrap(
      children: monitorItem.missedTasksPerDay
          .mapIndexed((index, missed) => Tooltip(
                message: _getTooltipText(
                    missed, monitorItem.completedTasksPerDay[index]),
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
                      (index + 1).toString(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  String _getTooltipText(
      Set<String> missedTaskIds, Set<String> completedTaskIds) {
    final sb = StringBuffer();
    for (final intervention in interventions) {
      for (final task in intervention.tasks) {
        if (missedTaskIds.contains(task.id)) {
          sb.writeln('❌ ${intervention.name} - ${task.title}');
        } else if (completedTaskIds.contains(task.id)) {
          sb.writeln('✅ ${intervention.name} - ${task.title}');
        }
      }
    }
    for (final observation in observations) {
      if (missedTaskIds.contains(observation.id)) {
        sb.writeln('❌ ${observation.title}');
      } else if (completedTaskIds.contains(observation.id)) {
        sb.writeln('✅ ${observation.title}');
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
                Colors.green, tr.participant_details_color_legend_completed),
            const SizedBox(width: 16.0),
            _buildLegendItem(Colors.orange,
                tr.participant_details_color_legend_partially_completed),
            const SizedBox(width: 16.0),
            _buildLegendItem(
                Colors.red, tr.participant_details_color_legend_missed),
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