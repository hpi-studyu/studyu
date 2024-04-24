import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ParticipantDetailsView extends StatelessWidget {
  const ParticipantDetailsView(
      {required this.monitorItem, required this.interventions, required this.observations, super.key});

  final StudyMonitorItem monitorItem;
  final List<Intervention> interventions;
  final List<Observation> observations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(rows: [
          FormTableRow(
            label: tr.monitoring_table_column_participant_id,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            input: ReactiveTextField(
              formControl: FormControl<String>(value: monitorItem.participantId),
              readOnly: true,
            ),
          ),
        ]),
        const SizedBox(height: 16.0),
        Align(
          alignment: Alignment.centerLeft,
          child: FormSectionHeader(
            title: tr.participant_details_study_days_overview,
          ),
        ),
        const SizedBox(height: 8.0),
        _buildPerDayStatus(context),
      ],
    );
  }

  Widget _buildPerDayStatus(BuildContext context) {
    assert(monitorItem.missedTasksPerDay.length == monitorItem.completedTasksPerDay.length);
    return Wrap(
      children: monitorItem.missedTasksPerDay
          .mapIndexed((index, missed) => Tooltip(
                message: _getTooltipText(missed, monitorItem.completedTasksPerDay[index]),
                child: Container(
                  height: 50,
                  width: 50,
                  margin: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                  decoration: BoxDecoration(
                    color: missed.isEmpty
                        ? Colors.green
                        : (monitorItem.completedTasksPerDay[index].isEmpty ? Colors.red : Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  String _getTooltipText(Set<String> missedTaskIds, Set<String> completedTaskIds) {
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
}
