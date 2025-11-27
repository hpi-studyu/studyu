import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/study_schedule_section.dart';

class SingleInterventionControls {
  final FormGroup segmentControl;
  final StudyScheduleControls formViewModel;

  const SingleInterventionControls({
    required this.segmentControl,
    required this.formViewModel,
  });

  List<Widget> build() {
    final selectedInterventions =
        formViewModel.selectedInterventionsControl.value ?? [];

    final valueToIndexMap = <String, int>{};
    final dropdownItems = <DropdownMenuItem<String>>[];

    // Add all defined interventions
    for (var i = 0; i < formViewModel.interventions.length; i++) {
      final intervention = formViewModel.interventions[i];
      valueToIndexMap[intervention.id] = i;
      dropdownItems.add(
        DropdownMenuItem(
          value: intervention.id,
          child: Text(intervention.name ?? intervention.id),
        ),
      );
    }

    // Add participant choice options
    if (selectedInterventions.isNotEmpty) {
      for (var i = 0; i < selectedInterventions.length; i++) {
        final choiceKey = 'choice_$i';
        valueToIndexMap[choiceKey] = i;
        dropdownItems.add(
          DropdownMenuItem(
            value: choiceKey,
            child: Text(
              "Choice ${String.fromCharCode(65 + i)} (Participant's ${_ordinal(i + 1)} selection)",
            ),
          ),
        );
      }
    }

    final indexControl =
        segmentControl.control('interventionIndex') as FormControl<int>;
    final currentIndex = indexControl.value ?? 0;

    // Find the string value that maps to current index
    String? currentValue;
    if (selectedInterventions.isNotEmpty &&
        currentIndex < selectedInterventions.length) {
      currentValue = 'choice_$currentIndex';
    } else if (currentIndex < formViewModel.interventions.length) {
      currentValue = formViewModel.interventions[currentIndex].id;
    }

    return [
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: currentValue,
              items: dropdownItems,
              onChanged: (value) {
                if (value != null && valueToIndexMap.containsKey(value)) {
                  indexControl.value = valueToIndexMap[value];
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Intervention',
                helperText:
                    'Select which intervention or participant choice to use',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('duration') as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Duration (days)',
              ),
              controller: ZeroValueController(),
            ),
          ),
        ],
      ),
    ];
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
