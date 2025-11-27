import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/study_schedule_section.dart';

class AlternatingControls {
  final FormGroup segmentControl;
  final StudyScheduleControls formViewModel;

  const AlternatingControls({
    required this.segmentControl,
    required this.formViewModel,
  });

  List<Widget> build() {
    final selectedInterventions =
        formViewModel.selectedInterventionsControl.value ?? [];
    final hasTwoInterventions = selectedInterventions.length == 2;

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
      if (hasTwoInterventions) ...[
        const SizedBox(height: 16),
        Row(
          children: [
            ReactiveCheckbox(
              formControl:
                  segmentControl.control('balanceFirstIntervention')
                      as FormControl<bool>,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Balance first intervention (50% start with A, 50% start with B)',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    ];
  }
}
