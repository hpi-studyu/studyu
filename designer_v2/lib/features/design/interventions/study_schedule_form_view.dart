import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudyScheduleFormView extends FormConsumerWidget {
  const StudyScheduleFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final StudyScheduleControls formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormTableLayout(rows: [
          FormTableRow(
            control: formViewModel.sequenceTypeControl,
            label: "Sequencing".hardcoded,
            labelHelpText: "TODO Sequencing help text".hardcoded,
            input: ReactiveDropdownField(
              formControl: formViewModel.sequenceTypeControl,
              decoration: InputDecoration(
                helperText:
                    "This is the default sequence of interventions for each participant. You may override this sequencing individually for each participant in invitation-based studies."
                        .hardcoded,
                helperMaxLines: 5,
              ),
              items: formViewModel.sequenceTypeControlOptions
                  .map((option) => DropdownMenuItem(
                        value: option.value,
                        child: Text(option.label),
                      ))
                  .toList(),
            ),
          ),
          FormTableRow(
              control: formViewModel.phaseDurationControl,
              label: "Phase length".hardcoded,
              labelHelpText: "TODO Phase length help text".hardcoded,
              input: Row(children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 70),
                  child: ReactiveTextField(
                    formControl: formViewModel.phaseDurationControl,
                  ),
                ),
                const SizedBox(width: 8.0),
                FormControlLabel(
                    formControl: formViewModel.phaseDurationControl,
                    text: "days".hardcoded),
              ])),
          FormTableRow(
              control: formViewModel.numCyclesControl,
              label: "Number of cycles".hardcoded,
              labelHelpText: "TODO Number of cycles help text".hardcoded,
              input: Row(children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 70),
                  child: ReactiveTextField(
                    formControl: formViewModel.numCyclesControl,
                  ),
                ),
                const SizedBox(width: 8.0),
                FormControlLabel(
                    formControl: formViewModel.numCyclesControl,
                    text: "cycles".hardcoded),
              ])),
          FormTableRow(
              control: formViewModel.includeBaselineControl,
              label: "Baseline phase".hardcoded,
              labelHelpText: "TODO Baseline phase help text".hardcoded,
              input: Row(children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 70),
                  child: ReactiveCheckbox(
                    formControl: formViewModel.includeBaselineControl,
                  ),
                ),
                const SizedBox(width: 8.0),
                FormControlLabel(
                    formControl: formViewModel.includeBaselineControl,
                    text: "Include in schedule".hardcoded),
              ])),
          // TODO washout
        ]),
      ],
    );
  }
}
