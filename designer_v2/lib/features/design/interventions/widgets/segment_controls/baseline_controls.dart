import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/study_schedule_section.dart';

class BaselineControls {
  final FormGroup segmentControl;

  const BaselineControls({required this.segmentControl});

  List<Widget> build() {
    return [
      ReactiveTextField(
        formControl:
            segmentControl.control('duration') as FormControl<dynamic>?,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Duration (days)',
          helperText: ' ',
        ),
        controller: ZeroValueController(),
      ),
    ];
  }
}
