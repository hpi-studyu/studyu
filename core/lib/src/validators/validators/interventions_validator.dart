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
  }

  return ValidationResult(errors: errors, warnings: []);
}
