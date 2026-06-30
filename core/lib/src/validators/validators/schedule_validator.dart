import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

ValidationResult validateSchedule(Study study, ValidationLevel level) {
  final errors = <ValidationError>[];

  if (study.schedule.phaseDuration <= 0) {
    errors.add(const ValidationError(
      code: 'schedule.phase_duration_invalid',
      path: r'$.schedule.phaseDuration',
      message: 'phaseDuration must be greater than 0',
      fixHint: 'Set phaseDuration to at least 1',
    ));
  }

  if (study.schedule.numberOfCycles <= 0) {
    errors.add(const ValidationError(
      code: 'schedule.number_of_cycles_invalid',
      path: r'$.schedule.numberOfCycles',
      message: 'numberOfCycles must be greater than 0',
      fixHint: 'Set numberOfCycles to at least 1',
    ));
  }

  return ValidationResult(errors: errors, warnings: []);
}
