import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class InviteCodeFormView extends FormConsumerWidget {
  const InviteCodeFormView({required this.formViewModel, super.key});

  final InviteCodeFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    return Column(
      children: [
        FormTableLayout(rows: [
          FormTableRow(
            label: tr.form_field_code,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            labelHelpText: tr.form_field_code_tooltip,
            control: formViewModel.codeControl,
            input: ReactiveTextField(
              formControl: formViewModel.codeControl,
              validationMessages: formViewModel.codeControlValidationMessages,
              decoration: (formViewModel.codeControl.enabled)
                  ? InputDecoration(
                      helperText: "",
                      suffixIcon: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            splashRadius: 18.0,
                            onPressed: formViewModel.regenerateCode,
                            icon: const Icon(Icons.refresh_rounded),
                          )))
                  : const InputDecoration(),
            ),
          ),
          FormTableRow(
            label: tr.form_field_is_preconfigured_schedule,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            input: ReactiveSwitch(
              formControl: formViewModel.isPreconfiguredScheduleControl,
            ),
          ),
        ]),
        const SizedBox(height: 4.0),
        TextParagraph(text: tr.form_field_is_preconfigured_schedule_description),
        const SizedBox(height: 24.0),
        FormTableLayout(rows: [
          ..._conditionalInterventionRows(context),
        ]),
      ],
    );
  }

  List<FormTableRow> _conditionalInterventionRows(BuildContext context) {
    if (!formViewModel.isPreconfiguredSchedule) {
      return [];
    }

    return [
      FormTableRow(
        label: tr.form_field_preconfigured_schedule_type,
        input: ReactiveDropdownField<PhaseSequence>(
          formControl: formViewModel.preconfiguredScheduleTypeControl,
          //decoration: const NullHelperDecoration(),
          readOnly: true,
          items: formViewModel.preconfiguredScheduleTypeOptions
              .map((option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ))
              .toList(),
        ),
      ),
      FormTableRow(
        label: tr.form_field_preconfigured_schedule_intervention_a,
        input: ReactiveDropdownField<String>(
          formControl: formViewModel.interventionAControl,
          hint: Text(tr.form_field_preconfigured_schedule_intervention_hint),
          //decoration: const NullHelperDecoration(),
          items: formViewModel.interventionControlOptions
              .map((option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ))
              .toList(),
        ),
      ),
      FormTableRow(
        label: tr.form_field_preconfigured_schedule_intervention_b,
        input: ReactiveDropdownField<String>(
          formControl: formViewModel.interventionBControl,
          hint: Text(tr.form_field_preconfigured_schedule_intervention_hint),
          //decoration: const NullHelperDecoration(),
          items: formViewModel.interventionControlOptions
              .map((option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ))
              .toList(),
        ),
      )
    ];
  }
}
