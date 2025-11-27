import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';

class InterventionAssignmentDropdowns {
  final FormGroup segmentControl;
  final StudyScheduleControls formViewModel;

  const InterventionAssignmentDropdowns({
    required this.segmentControl,
    required this.formViewModel,
  });

  List<Widget> build() {
    final selectedInterventions =
        formViewModel.selectedInterventionsControl.value ?? [];

    final dropdownItems = _buildDropdownItems(selectedInterventions);
    final idsControl =
        segmentControl.control('interventionIds') as FormControl<List<String>>;
    final currentIds = idsControl.value ?? [];
    final posAValue = currentIds.isNotEmpty ? currentIds[0] : null;
    final posBValue = currentIds.length > 1 ? currentIds[1] : null;

    return [
      const Text(
        'Intervention Assignment',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: posAValue,
              items: dropdownItems,
              onChanged: (value) {
                if (value != null) {
                  final newIds = [value, posBValue ?? value];
                  idsControl.value = newIds;
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Position A',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: posBValue,
              items: dropdownItems,
              onChanged: (value) {
                if (value != null) {
                  final newIds = [posAValue ?? value, value];
                  idsControl.value = newIds;
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Position B',
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
    List<String> selectedInterventions,
  ) {
    final List<DropdownMenuItem<String>> items = [];

    // Add all defined interventions
    for (final intervention in formViewModel.interventions) {
      items.add(
        DropdownMenuItem(
          value: intervention.id,
          child: Text(intervention.name ?? intervention.id),
        ),
      );
    }

    // Add participant choice options
    if (selectedInterventions.isNotEmpty) {
      for (var i = 0; i < selectedInterventions.length; i++) {
        items.add(
          DropdownMenuItem(
            value: 'choice_$i',
            child: Text(
              "Choice ${String.fromCharCode(65 + i)} (Participant's ${_ordinal(i + 1)} selection)",
            ),
          ),
        );
      }
    }

    return items;
  }

  String _ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}
