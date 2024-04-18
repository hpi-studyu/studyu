import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/monitor/participant_details_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ParticipantDetailsFormView extends FormConsumerWidget {
  const ParticipantDetailsFormView({required this.formViewModel, super.key});

  final ParticipantDetailsFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    return Column(
      children: [
        FormTableLayout(rows: [
          FormTableRow(
            label: tr.monitoring_table_column_participant_id,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            control: formViewModel.participantIdControl,
            input: ReactiveTextField(
              formControl: formViewModel.participantIdControl,
              readOnly: true,
            ),
          ),
        ]),
        const SizedBox(height: 16.0),
        Align(
          alignment: Alignment.centerLeft,
          child: FormLabel(
              labelText: tr.participant_details_raw_data,
              labelTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ),
        const SizedBox(height: 8.0),
        ReactiveTextField(
          formControl: formViewModel.rawDataControl,
          maxLines: null,
          readOnly: true,
        ),
      ],
    );
  }
}
