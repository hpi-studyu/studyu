import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/interventions/schedule_creator/schedule_creator.dart';
import 'package:studyu_designer_v2/features/design/interventions/mp23_study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/input_formatter.dart';

class MP23StudyScheduleFormView extends FormConsumerWidget {
  const MP23StudyScheduleFormView({required this.formViewModel, super.key});

  final MP23StudyScheduleControls formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            constraints: const BoxConstraints(
                maxWidth: 600, minHeight: 200, minWidth: 560),
            child: Row(
              children: [
                const Text('Study Schedule'),
                const Spacer(),
                ReactiveFormConsumer(
                    builder: (context, form, child) => TextButton(
                          onPressed: () {
                            formViewModel.addFormGroupToSegments(
                                formViewModel.createBaselineFormGroup());
                          },
                          child: const Text('Add Baseline'),
                        )),
                const Spacer(),
                ReactiveFormConsumer(
                    builder: (context, form, child) => TextButton(
                          onPressed: () {
                            formViewModel.addFormGroupToSegments(
                                formViewModel.createAlternatingFormGroup());
                          },
                          child: const Text('Add Alternating'),
                        )),
                const Spacer(),
                ReactiveFormConsumer(
                    builder: (context, form, child) => TextButton(
                          onPressed: () {
                            formViewModel.addFormGroupToSegments(formViewModel
                                .createThompsonSamplingFormGroup());
                          },
                          child: const Text('Add Thompson Sampling'),
                        )),
              ],
            ))
      ],
    );
  }
}
