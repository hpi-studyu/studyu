import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/recruit/invite_code_form_controller.dart';
import 'package:studyu_designer_v2/domain/study_schedule.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class InviteCodeFormView extends FormConsumerWidget {
  const InviteCodeFormView({
    required this.formViewModel,
    Key? key
  }) : super(key: key);

  final InviteCodeFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: tr.code,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              labelHelpText: tr.access_code_help_text,
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
                            )
                        )
                    ) : const InputDecoration(),
              ),
            ),
            FormTableRow(
              label: tr.predefined_schedule,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              input: ReactiveSwitch(
                formControl: formViewModel.isPreconfiguredScheduleControl,
              ),
            ),
          ]
        ),
        Text(
          tr.predefined_schedule_help_text,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(
            height: 1.35,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85)),
        ),
        const SizedBox(height: 24.0),
        FormTableLayout(
            rows: [
              ..._conditionalInterventionRows(context),
            ]
        ),
      ],
    );
  }

  List<FormTableRow> _conditionalInterventionRows(BuildContext context) {
    if (!formViewModel.isPreconfiguredSchedule) {
      return [];
    }

    return [
      FormTableRow(
        label: tr.schedule,
        input: ReactiveDropdownField<StudyScheduleType>(
          formControl: formViewModel.preconfiguredScheduleTypeControl,
          //decoration: const NullHelperDecoration(),
          readOnly: true,
          items: formViewModel.preconfiguredScheduleTypeOptions.map(
                  (option) => DropdownMenuItem(
                value: option.value,
                child: Text(option.label),
              )).toList(),
        ),
      ),
      FormTableRow(
        label: tr.intervention_a,
        input: ReactiveDropdownField<String>(
          formControl: formViewModel.interventionAControl,
          hint: Text(tr.selection_intervention),
          //decoration: const NullHelperDecoration(),
          items: formViewModel.interventionControlOptions.map(
                  (option) => DropdownMenuItem(
                value: option.value,
                child: Text(option.label),
              )).toList(),
        ),
      ),
      FormTableRow(
        label: tr.intervention_b,
        input: ReactiveDropdownField<String>(
          formControl: formViewModel.interventionBControl,
          hint: Text(tr.selection_intervention),
          //decoration: const NullHelperDecoration(),
          items: formViewModel.interventionControlOptions.map(
                  (option) => DropdownMenuItem(
                value: option.value,
                child: Text(option.label),
              )).toList(),
        ),
      )
    ];
  }
}
