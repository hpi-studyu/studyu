import 'package:studyu_core/src/models/questionnaire/questionnaire.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/question_type_validator.dart';

ValidationResult validateQuestionnaire(
  StudyUQuestionnaire questionnaire,
  String context,
  ValidationLevel level, {
  Set<String>? knownIds,
}) {
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

    // Per-type validation
    final questionResult =
        validateQuestion(q, '$context[$i]', level, seenIds);
    errors.addAll(questionResult.errors);
  }

  // Fact 14 — cross-context duplicate ID check
  if (knownIds != null) {
    for (final id in seenIds) {
      if (knownIds.contains(id)) {
        errors.add(ValidationError(
          code: 'questionnaire.duplicate_question_id_cross_context',
          path: '$context.questions',
          message:
              'Question id "$id" appears in both the screener and an observation questionnaire',
          fixHint:
              'Assign unique IDs across all questionnaires in the study. This cannot happen via the Designer UI; it indicates a manual JSON edit.',
        ));
      }
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}
