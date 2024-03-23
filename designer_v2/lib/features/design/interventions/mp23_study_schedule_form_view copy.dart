import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/features/design/interventions/mp23_study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/schedule_creator.dart';

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
          child: ReorderableExample(),
        )
      ],
    );
  }
}
