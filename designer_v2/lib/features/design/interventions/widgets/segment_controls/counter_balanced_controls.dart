import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/study_schedule_section.dart';

class CounterBalancedControls {
  final FormGroup segmentControl;
  final StudyScheduleControls formViewModel;

  const CounterBalancedControls({
    required this.segmentControl,
    required this.formViewModel,
  });

  List<Widget> build() {
    final totalInterventions = formViewModel.interventions.length;
    final hasTwoInterventions = totalInterventions == 2;

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
                'Balance first intervention',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        // Show slider when balancing is enabled
        ReactiveValueListenableBuilder<bool>(
          formControl:
              segmentControl.control('balanceFirstIntervention')
                  as FormControl<bool>,
          builder: (context, control, child) {
            final isBalancingEnabled = control.value ?? false;
            if (!isBalancingEnabled) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Balance Ratio',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                ReactiveValueListenableBuilder<double>(
                  formControl:
                      segmentControl.control('balanceRatio')
                          as FormControl<double>,
                  builder: (context, ratioControl, child) {
                    final ratio = ratioControl.value ?? 0.5;
                    final percentA = (ratio * 100).round();
                    final percentB = 100 - percentA;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$percentA% start with A, $percentB% start with B',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        ReactiveSlider(
                          formControl:
                              segmentControl.control('balanceRatio')
                                  as FormControl<double>,
                          divisions: 20,
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    ];
  }
}
