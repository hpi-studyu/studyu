import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class InviteCodeFormView extends FormConsumerWidget {
  const InviteCodeFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final InviteCodeFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    return Column(
      children: [
        FormTableLayout(rows: [
          FormTableRow(
            label: "Code".hardcoded,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            labelHelpText: "TODO Access code help text".hardcoded,
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
            label: "Predefined Schedule".hardcoded,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            input: ReactiveSwitch(
              formControl: formViewModel.isPreconfiguredScheduleControl,
            ),
          ),
        ]),
        const SizedBox(height: 4.0),
        TextParagraph(
            text: "You can predefine the phases & interventions for any participant "
                    "who joins your study via this access code. If enabled, these "
                    "settings will override the default schedule defined in your study "
                    "design."
                .hardcoded),
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
        label: "Schedule".hardcoded,
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
        label: "Intervention A".hardcoded,
        input: ReactiveDropdownField<String>(
          formControl: formViewModel.interventionAControl,
          hint: Text('Select intervention...'.hardcoded),
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
        label: "Intervention B".hardcoded,
        input: ReactiveDropdownField<String>(
          formControl: formViewModel.interventionBControl,
          hint: Text('Select intervention...'.hardcoded),
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
