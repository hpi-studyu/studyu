import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_controls_view.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class InterventionTaskFormView extends StatelessWidget {
  const InterventionTaskFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final InterventionTaskFormViewModel formViewModel;

  @override
  Widget build(BuildContext context) {
    return /* PointerInterceptor( // does not work on re-render for some reason
        debug: true,
        child: */ Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormTableLayout(rows: [
          FormTableRow(
            control: formViewModel.taskTitleControl,
            label: "Title".hardcoded,
            labelHelpText: "TODO Intervention title text help text".hardcoded,
            input: ReactiveTextField(
              formControl: formViewModel.taskTitleControl,
            ),
          ),
          FormTableRow(
            control: formViewModel.taskDescriptionControl,
            label: "Description".hardcoded,
            labelHelpText:
                "TODO Intervention description text help text".hardcoded,
            input: ReactiveTextField(
              formControl: formViewModel.taskDescriptionControl,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Give a detailed description of the task to be "
                  "performed, link to a video instruction, etc".hardcoded
              ),
            ),
          ),

        ]),
        const SizedBox(height: 12.0),
        FormSectionHeader(title: "Compliance".hardcoded),
        const SizedBox(height: 12.0),
        ReactiveFormConsumer(builder: (context, form, child) {
          return Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ReactiveCheckbox(
                  formControl: formViewModel.markAsCompletedControl,
                ),
                const SizedBox(width: 3.0),
                FormControlLabel(
                    formControl: formViewModel.markAsCompletedControl,
                    text:
                    'Require participants to "Mark as completed"'.hardcoded),
              ]
          );
        }),
        const SizedBox(height: 24.0),
        ScheduleControls(formViewModel: formViewModel),
      ],
      //)
    );
  }
}
