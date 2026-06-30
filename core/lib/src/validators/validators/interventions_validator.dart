import 'package:studyu_core/src/models/study_schedule/study_schedule.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

ValidationResult validateInterventions(Study study, ValidationLevel level) {
  final errors = <ValidationError>[];

  if (level == ValidationLevel.publish && study.interventions.isEmpty) {
    errors.add(const ValidationError(
      code: 'interventions.at_least_one_required',
      path: r'$.interventions',
      message: 'At least one intervention is required for publishing',
      fixHint: 'Add an intervention',
    ));
  }

  // Fact 15 — duplicate intervention IDs
  final seenInterventionIds = <String>{};
  for (var i = 0; i < study.interventions.length; i++) {
    final intervention = study.interventions[i];

    if (intervention.name == null || intervention.name!.trim().isEmpty) {
      errors.add(ValidationError(
        code: 'interventions.name_required',
        path: r'$.interventions[' + i.toString() + r'].name',
        message: 'Intervention at index $i has no name',
        fixHint: 'Set a name for the intervention',
      ));
    }

    if (seenInterventionIds.contains(intervention.id)) {
      errors.add(ValidationError(
        code: 'interventions.duplicate_intervention_id',
        path: r'$.interventions[' + i.toString() + r'].id',
        message:
            'Intervention id "${intervention.id}" appears more than once',
        fixHint:
            'Regenerate a unique UUID for each intervention. This cannot happen via the Designer UI; it indicates a manual JSON edit.',
      ));
    }
    seenInterventionIds.add(intervention.id);
  }

  // Fact 17 — duplicate task IDs across all interventions
  final seenTaskIds = <String>{};
  for (var i = 0; i < study.interventions.length; i++) {
    final tasks = study.interventions[i].tasks;
    for (var j = 0; j < tasks.length; j++) {
      final taskId = tasks[j].id;
      if (seenTaskIds.contains(taskId)) {
        errors.add(ValidationError(
          code: 'interventions.duplicate_task_id',
          path: r'$.interventions[' +
              i.toString() +
              r'].tasks[' +
              j.toString() +
              r'].id',
          message:
              'Task id "$taskId" appears more than once across interventions',
          fixHint:
              'Regenerate a unique UUID for each task. This cannot happen via the Designer UI; it indicates a manual JSON edit.',
        ));
      }
      seenTaskIds.add(taskId);
    }
  }

  if (level == ValidationLevel.publish) {
    // Fact 16 — count-must-be-two for non-customized sequence
    final seq = study.schedule.sequence;
    final isCustom = seq == PhaseSequence.customized;
    if (!isCustom && study.interventions.length != 2) {
      errors.add(ValidationError(
        code: 'interventions.count_must_be_two_for_sequence',
        path: r'$.interventions',
        message:
            'Sequence type "${seq.name}" requires exactly 2 interventions; found ${study.interventions.length}',
        fixHint:
            'Add or remove interventions to reach exactly 2, or switch to a customized sequence.',
      ));
    }

    // Fact 18 — no tasks in an intervention
    for (var i = 0; i < study.interventions.length; i++) {
      if (study.interventions[i].tasks.isEmpty) {
        errors.add(ValidationError(
          code: 'interventions.no_tasks',
          path: r'$.interventions[' + i.toString() + r'].tasks',
          message: 'Intervention at index $i has no tasks',
          fixHint:
              'Add at least one task. In the Designer, the "Add Task" button is in the intervention detail view.',
        ));
      }
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}
