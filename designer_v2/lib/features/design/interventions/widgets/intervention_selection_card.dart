import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';

class InterventionSelectionCard extends StatefulWidget {
  final StudyScheduleControls formViewModel;

  const InterventionSelectionCard({required this.formViewModel, super.key});

  @override
  State<InterventionSelectionCard> createState() =>
      _InterventionSelectionCardState();
}

class _InterventionSelectionCardState extends State<InterventionSelectionCard> {
  @override
  void initState() {
    super.initState();
    // Listen to min changes and ensure max is always >= min
    widget.formViewModel.minInterventionsToSelectControl.valueChanges.listen((
      minValue,
    ) {
      if (minValue != null) {
        final currentMax =
            widget.formViewModel.maxInterventionsToSelectControl.value;
        if (currentMax == null || currentMax < minValue) {
          widget.formViewModel.maxInterventionsToSelectControl.value = minValue;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalInterventions = widget.formViewModel.interventions.length;

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
              'Select which interventions participants can choose from.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.formViewModel.interventions.map((intervention) {
                final selectedInterventions =
                    widget.formViewModel.selectedInterventionsControl.value ??
                    [];
                final isSelected = selectedInterventions.contains(
                  intervention.id,
                );
                return FilterChip(
                  label: Text(intervention.name ?? intervention.id),
                  selected: isSelected,
                  onSelected: (selected) {
                    final currentValue =
                        widget
                            .formViewModel
                            .selectedInterventionsControl
                            .value ??
                        [];
                    final newValue = List<String>.from(currentValue);
                    if (selected) {
                      if (!newValue.contains(intervention.id)) {
                        newValue.add(intervention.id);
                      }
                    } else {
                      newValue.remove(intervention.id);
                    }
                    widget.formViewModel.selectedInterventionsControl.value =
                        newValue;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            ReactiveValueListenableBuilder<List<String>>(
              formControl: widget.formViewModel.selectedInterventionsControl,
              builder: (context, selectedControl, child) {
                final selectedCount = (selectedControl.value ?? []).length;
                if (selectedCount < 2) {
                  return const SizedBox.shrink();
                }
                return Row(
                  children: [
                    Expanded(
                      child: ReactiveDropdownField<int>(
                        formControl: widget
                            .formViewModel
                            .minInterventionsToSelectControl,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Minimum Interventions',
                          helperText: 'Min number participants must select',
                        ),
                        items: List.generate(
                          selectedCount - 1,
                          (index) => DropdownMenuItem(
                            value: index + 2,
                            child: Text('${index + 2}'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ReactiveValueListenableBuilder<int>(
                        formControl: widget
                            .formViewModel
                            .minInterventionsToSelectControl,
                        builder: (context, minControl, child) {
                          final minValue = minControl.value ?? 2;
                          return ReactiveDropdownField<int>(
                            formControl: widget
                                .formViewModel
                                .maxInterventionsToSelectControl,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Maximum Interventions',
                              helperText: 'Max number participants can select',
                            ),
                            items: List.generate(
                              selectedCount - minValue + 1,
                              (index) => DropdownMenuItem(
                                value: minValue + index,
                                child: Text('${minValue + index}'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
