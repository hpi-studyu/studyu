import 'package:studyu_core/src/models/expressions/expression.dart';
import 'package:studyu_core/src/models/expressions/types/composite_expression.dart';
import 'package:studyu_core/src/models/expressions/types/value_expression.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

Set<String> _extractTargets(Expression expr) {
  if (expr is ValueExpression) {
    return {if (expr.target != null) expr.target!};
  }
  if (expr is CompositeExpression) {
    return expr.expressions.expand(_extractTargets).toSet();
  }
  return {};
}

ValidationResult validateEligibilityConsent(
    Study study, ValidationLevel level) {
  final errors = <ValidationError>[];
  final screenerIds =
      study.questionnaire.questions.map((q) => q.id).toSet();

  for (var i = 0; i < study.eligibilityCriteria.length; i++) {
    final criterion = study.eligibilityCriteria[i];
    final targets = _extractTargets(criterion.condition);

    for (final target in targets) {
      if (!screenerIds.contains(target)) {
        errors.add(ValidationError(
          code: 'eligibility.target_question_missing',
          path: r'$.eligibility_criteria' + '[$i].condition.target',
          message:
              "Criterion references question '$target' which does not exist in questionnaire",
          fixHint: 'Add the screener question first, or remove this criterion',
        ));
      }
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}
