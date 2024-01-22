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


  @override
  Widget build(BuildContext context, FormGroup form) {
    // var num_interventions = formViewModel.interventionsArray.length;

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
