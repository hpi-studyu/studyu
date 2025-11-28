import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';

class InterventionSelectionCard extends StatelessWidget {
  final StudyScheduleControls formViewModel;

  const InterventionSelectionCard({required this.formViewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalInterventions = formViewModel.interventions.length;

    if (totalInterventions < 2) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please define at least 2 interventions to configure participant selection',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participant Intervention Selection',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Participants will select interventions from all $totalInterventions defined interventions at study start.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue:
                        formViewModel.minInterventionsToSelectControl.value,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Minimum Interventions',
                      helperText: 'Min number participants must select',
                    ),
                    items: List.generate(
                      totalInterventions,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        formViewModel.minInterventionsToSelectControl.value =
                            value;
                        // Ensure max is at least min
                        final currentMax =
                            formViewModel
                                .maxInterventionsToSelectControl
                                .value ??
                            value;
                        if (currentMax < value) {
                          formViewModel.maxInterventionsToSelectControl.value =
                              value;
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue:
                        formViewModel.maxInterventionsToSelectControl.value,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Maximum Interventions',
                      helperText: 'Max number participants can select',
                    ),
                    items: List.generate(
                      totalInterventions,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        formViewModel.maxInterventionsToSelectControl.value =
                            value;
                        // Ensure min is at most max
                        final currentMin =
                            formViewModel
                                .minInterventionsToSelectControl
                                .value ??
                            value;
                        if (currentMin > value) {
                          formViewModel.minInterventionsToSelectControl.value =
                              value;
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
