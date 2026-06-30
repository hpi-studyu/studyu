import 'package:studyu_core/src/models/questionnaire/questionnaire.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

ValidationResult validateQuestionnaire(
  StudyUQuestionnaire questionnaire,
  String context,
  ValidationLevel level,
) {
  final errors = <ValidationError>[];
  final seenIds = <String>{};

  for (var i = 0; i < questionnaire.questions.length; i++) {
    final q = questionnaire.questions[i];
    if (seenIds.contains(q.id)) {
      errors.add(ValidationError(
        code: 'questionnaire.duplicate_question_id',
        path: '$context[$i].id',
        message: 'Question id "${q.id}" appears more than once in $context',
        fixHint: 'Generate a unique UUID for each question',
      ));
    }
    seenIds.add(q.id);
  }

  return ValidationResult(errors: errors, warnings: []);
}
