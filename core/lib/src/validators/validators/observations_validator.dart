import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

ValidationResult validateObservations(Study study, ValidationLevel level) {
  final errors = <ValidationError>[];
  final seenIds = <String>{};

  for (var i = 0; i < study.observations.length; i++) {
    final id = study.observations[i].id;
    if (seenIds.contains(id)) {
      errors.add(ValidationError(
        code: 'observations.duplicate_observation_id',
        path: r'$.observations[' + i.toString() + r'].id',
        message: 'Observation id "$id" appears more than once',
        fixHint:
            'Regenerate a unique UUID for each observation. This cannot happen via the Designer UI; it indicates a manual JSON edit.',
      ));
    }
    seenIds.add(id);
  }

  return ValidationResult(errors: errors, warnings: []);
}
