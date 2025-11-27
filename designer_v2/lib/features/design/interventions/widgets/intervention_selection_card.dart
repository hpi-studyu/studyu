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
              'Select which interventions participants can choose from. Participants will select 2 interventions from this list.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: formViewModel.interventions.map((intervention) {
                final isSelected =
                    (formViewModel.selectedInterventionsControl.value ?? [])
                        .contains(intervention.id);
                return FilterChip(
                  label: Text(intervention.name ?? intervention.id),
                  selected: isSelected,
                  onSelected: (selected) {
                    final currentValue =
                        formViewModel.selectedInterventionsControl.value ?? [];
                    final newValue = List<String>.from(currentValue);
                    if (selected) {
                      if (!newValue.contains(intervention.id)) {
                        newValue.add(intervention.id);
                      }
                    } else {
                      newValue.remove(intervention.id);
                    }
                    formViewModel.selectedInterventionsControl.value =
                        newValue.isEmpty ? [] : newValue;
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
