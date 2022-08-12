import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

// TODO scheduling form fields
class InterventionTaskFormView extends StatelessWidget {
  const InterventionTaskFormView({
    required this.formViewModel,
    Key? key
  }) : super(key: key);

  final InterventionTaskFormViewModel formViewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(
            rows: [
              FormTableRow(
                label: "Title".hardcoded,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelHelpText: "TODO Intervention title text help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.taskTitleControl,
                ),
              ),
              FormTableRow(
                label: "Description".hardcoded,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelHelpText: "TODO Intervention description text help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.taskDescriptionControl,
                ),
              ),
            ]
        ),
      ],
    );
  }
}
