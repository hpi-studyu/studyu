import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/interventions/schedule_creator/schedule_creator.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/input_formatter.dart';

class StudyScheduleFormView extends FormConsumerWidget {
  const StudyScheduleFormView({required this.formViewModel, super.key});

  final StudyScheduleControls formViewModel;

  FormTableRow _renderCustomSequence() {
    if (!formViewModel.isSequencingCustom()) {
      return FormTableRow(input: const SizedBox.shrink());
    } else {
      return FormTableRow(
          control: formViewModel.sequenceTypeCustomControl,
          label: "Custom Sequence",
          // todo translate
          labelHelpText: "Enter a custom sequence by using the letters A and B",
          // todo translate
          input: ReactiveTextField(
            formControl: formViewModel.sequenceTypeCustomControl,
            keyboardType: TextInputType.text,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter,
              LengthLimitingTextInputFormatter(10),
              StudySequenceFormatter(),
            ],
            validationMessages:
                formViewModel.sequenceTypeCustomControl.validationMessages,
          ));
    }
  }

  @override
  Widget build(BuildContext context, FormGroup form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              control: formViewModel.sequenceTypeControl,
              label: tr.form_field_crossover_schedule_sequence,
              labelHelpText: tr.form_field_crossover_schedule_sequence_tooltip,
              input: ReactiveDropdownField(
                formControl: formViewModel.sequenceTypeControl,
                decoration: InputDecoration(
                  helperText:
                      tr.form_field_crossover_schedule_sequence_description,
                  helperMaxLines: 5,
                ),
                items: formViewModel.sequenceTypeControlOptions
                    .map((option) => DropdownMenuItem(
                          value: option.value,
                          child: Text(option.label),
                        ))
                    .toList(),
                validationMessages:
                    formViewModel.sequenceTypeControl.validationMessages,
              ),
            ),
            _renderCustomSequence(),
            FormTableRow(
              control: formViewModel.phaseDurationControl,
              label: tr.form_field_crossover_schedule_phase_length,
              labelHelpText:
                  tr.form_field_crossover_schedule_phase_length_tooltip,
              input: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 70),
                    child: ReactiveTextField(
                      formControl: formViewModel.phaseDurationControl,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                        NumericalRangeFormatter(
                          min: StudyScheduleControls.kPhaseDurationMin,
                          max: StudyScheduleControls.kPhaseDurationMax,
                        ),
                      ],
                      validationMessages:
                          formViewModel.phaseDurationControl.validationMessages,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FormControlLabel(
                    formControl: formViewModel.phaseDurationControl,
                    text: tr.form_field_amount_days,
                  ),
                ],
              ),
            ),
            FormTableRow(
              control: formViewModel.numCyclesControl,
              label: tr.form_field_crossover_schedule_num_cycles,
              labelHelpText:
                  tr.form_field_crossover_schedule_num_cycles_tooltip,
              input: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 70),
                    child: ReactiveTextField(
                      formControl: formViewModel.numCyclesControl,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                        NumericalRangeFormatter(
                          min: StudyScheduleControls.kNumCyclesMin,
                          max: StudyScheduleControls.kNumCyclesMax,
                        ),
                      ],
                      validationMessages:
                          formViewModel.numCyclesControl.validationMessages,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FormControlLabel(
                    formControl: formViewModel.numCyclesControl,
                    text: tr.form_field_amount_crossover_schedule_num_cycles,
                  ),
                ],
              ),
            ),
            FormTableRow(
              control: formViewModel.includeBaselineControl,
              label: tr.form_field_crossover_schedule_include_baseline,
              labelHelpText:
                  tr.form_field_crossover_schedule_include_baseline_tooltip,
              input: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 70),
                    child: ReactiveCheckbox(
                      formControl: formViewModel.includeBaselineControl,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FormControlLabel(
                    formControl: formViewModel.includeBaselineControl,
                    text:
                        tr.form_field_crossover_schedule_include_baseline_label,
                  ),
                ],
              ),
            ),
            FormTableRow(
              // control: formViewModel.includeBaselineControl,
              label: "Schedule",
              // labelHelpText:
              //     tr.form_field_crossover_schedule_include_baseline_tooltip,
              input: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(
                        maxWidth: 560, minHeight: 200, minWidth: 560),
                    child: ReorderableExample(),
                  ),
                  const SizedBox(width: 8.0),
                  // FormControlLabel(
                  //   formControl: formViewModel.includeBaselineControl,
                  //   text:
                  //       tr.form_field_crossover_schedule_include_baseline_label,
                  // ),
                ],
              ),
            ),
            // FormTableRow(
            //   control: formViewModel.demoControl,
            //   label: tr.form_field_crossover_schedule_num_cycles,
            //   labelHelpText:
            //       tr.form_field_crossover_schedule_num_cycles_tooltip,
            //   input: Row(
            //     children: [
            //       Container(
            //         constraints: const BoxConstraints(maxWidth: 70),
            //         child: ReactiveTextField(
            //           formControl: formViewModel.demoControl,
            //           keyboardType: TextInputType.number,
            //           inputFormatters: <TextInputFormatter>[
            //             FilteringTextInputFormatter.digitsOnly,
            //             LengthLimitingTextInputFormatter(2),
            //             NumericalRangeFormatter(
            //               min: 0,
            //               max: 2,
            //             ),
            //           ],
            //           validationMessages:
            //               formViewModel.demoControl.validationMessages,
            //         ),
            //       ),
            //       const SizedBox(width: 8.0),
            //       FormControlLabel(
            //         formControl: formViewModel.demoControl,
            //         text: "hellO!",
            //       ),
            //     ],
            //   ),
            // ),
          ],
          columnWidths: const {
            0: MaxColumnWidth(FixedColumnWidth(130), IntrinsicColumnWidth()),
            1: FlexColumnWidth(),
          },
        ),
      ],
    );
  }
}
