import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/segment_controls/shared/intervention_assignment_dropdowns.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/study_schedule_section.dart';

class AlternatingControls {
  final FormGroup segmentControl;
  final StudyScheduleControls formViewModel;

  const AlternatingControls({
    required this.segmentControl,
    required this.formViewModel,
  });

  List<Widget> build() {
    return [
      Row(
        children: [
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('interventionDuration')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Intervention Duration',
              ),
              controller: ZeroValueController(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('cycleAmount')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Cycle Amount',
              ),
              controller: ZeroValueController(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ...InterventionAssignmentDropdowns(
        segmentControl: segmentControl,
        formViewModel: formViewModel,
      ).build(),
    ];
  }
}
