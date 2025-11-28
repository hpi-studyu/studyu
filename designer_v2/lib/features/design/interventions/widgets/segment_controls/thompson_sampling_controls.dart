import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/interventions/study_schedule_form_controller_mixin.dart';
import 'package:studyu_designer_v2/features/design/interventions/widgets/study_schedule_section.dart';

class ThompsonSamplingControls {
  final FormGroup segmentControl;
  final StudyScheduleControls formViewModel;

  const ThompsonSamplingControls({
    required this.segmentControl,
    required this.formViewModel,
  });

  List<Widget> build() {
    return [
      Row(
        children: [
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('interventionDuration')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Intervention Duration',
              ),
              controller: ZeroValueController(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ReactiveTextField(
              formControl:
                  segmentControl.control('interventionDrawAmount')
                      as FormControl<dynamic>?,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Intervention Draw Amount',
              ),
              controller: ZeroValueController(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      Builder(
        builder: (context) => Text(
          "Deciding Metric",
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue:
            (segmentControl.control('observationId').value as String).isEmpty
            ? null
            : (segmentControl.control('observationId').value as String),
        items: formViewModel.observations
            .map(
              (observation) => DropdownMenuItem(
                value: observation.id,
                child: Text(observation.title ?? observation.id),
              ),
            )
            .toList(),
        onChanged: (String? observationId) {
          segmentControl.control('observationId').updateValue(observationId);
          segmentControl.control('questionId').updateValue('');
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Survey',
        ),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue:
            (segmentControl.control('questionId').value as String).isEmpty
            ? null
            : (segmentControl.control('questionId').value as String),
        items: formViewModel.observations
            .whereType<QuestionnaireTask>()
            .where(
              (observation) =>
                  observation.id ==
                  segmentControl.control('observationId').value,
            )
            .expand(
              (observation) => observation.questions.questions.map(
                (question) => DropdownMenuItem<String>(
                  value: question.id,
                  child: Text(question.prompt ?? question.id),
                ),
              ),
            )
            .toSet()
            .toList(),
        onChanged: (String? questionId) {
          segmentControl.control('questionId').updateValue(questionId);
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Question',
        ),
      ),
    ];
  }
}
