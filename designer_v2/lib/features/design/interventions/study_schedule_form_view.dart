import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
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
        label: tr.phase_sequence_custom_label,
        labelHelpText: tr.phase_sequence_custom_label_help,
        input: TextField(
          onChanged: (value) =>
              formViewModel.sequenceTypeCustomControl.value = value,
          controller: TextEditingController()
            ..value = TextEditingValue(
              text: formViewModel.sequenceTypeCustomControl.value!,
              selection: TextSelection.collapsed(
                offset: formViewModel.sequenceTypeCustomControl.value!.length,
              ),
            ),
          //formControl: formViewModel.sequenceTypeCustomControl,
          keyboardType: TextInputType.text,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.singleLineFormatter,
            LengthLimitingTextInputFormatter(10),
            StudySequenceFormatter(),
          ],
          //validationMessages: formViewModel.sequenceTypeCustomControl.validationMessages,
        ),
      );
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
              input: DropdownButtonFormField(
                //formControl: formViewModel.sequenceTypeControl,
                onChanged: formViewModel.sequenceTypeControl.disabled
                    ? null
                    : (PhaseSequence? value) =>
                        formViewModel.sequenceTypeControl.value = value,
                value: formViewModel.sequenceTypeControl.value,
                decoration: InputDecoration(
                  helperText:
                      tr.form_field_crossover_schedule_sequence_description,
                  helperMaxLines: 5,
                ),
                items: formViewModel.sequenceTypeControlOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option.value,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                //validationMessages: formViewModel.sequenceTypeControl.validationMessages,
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
                    child: TextField(
                      readOnly: formViewModel.phaseDurationControl.disabled,
                      controller: TextEditingController()
                        ..value = TextEditingValue(
                          text: formViewModel.phaseDurationControl.value
                              .toString(),
                          selection: TextSelection.collapsed(
                            offset: formViewModel.phaseDurationControl.value
                                .toString()
                                .length,
                          ),
                        ),
                      //formControl: formViewModel.phaseDurationControl,
                      onChanged: (value) => formViewModel
                          .phaseDurationControl.value = int.parse(value),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                        NumericalRangeFormatter(
                          min: StudyScheduleControls.kPhaseDurationMin,
                          max: StudyScheduleControls.kPhaseDurationMax,
                        ),
                      ],
                      //validationMessages: formViewModel.phaseDurationControl.validationMessages,
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
                    child: TextField(
                      readOnly: formViewModel.numCyclesControl.disabled,
                      //formControl: formViewModel.numCyclesControl,
                      onChanged: (value) => formViewModel
                          .numCyclesControl.value = int.parse(value),
                      controller: TextEditingController()
                        ..value = TextEditingValue(
                          text: formViewModel.numCyclesControl.value.toString(),
                          selection: TextSelection.collapsed(
                            offset: formViewModel.numCyclesControl.value
                                .toString()
                                .length,
                          ),
                        ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                        NumericalRangeFormatter(
                          min: StudyScheduleControls.kNumCyclesMin,
                          max: StudyScheduleControls.kNumCyclesMax,
                        ),
                      ],
                      //validationMessages: formViewModel.numCyclesControl.validationMessages,
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
                    child: Checkbox(
                      value: formViewModel.includeBaselineControl.value,
                      onChanged: formViewModel.includeBaselineControl.disabled
                          ? null
                          : (value) => formViewModel
                              .includeBaselineControl.value = value,
                      //formControl: formViewModel.includeBaselineControl,
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
            // TODO washout
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
