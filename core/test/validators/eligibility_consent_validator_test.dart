import 'package:studyu_core/src/models/eligibility/eligibility_criterion.dart';
import 'package:studyu_core/src/models/expressions/types/choice_expression.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire.dart';
import 'package:studyu_core/src/models/questionnaire/questions/boolean_question.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/eligibility_consent_validator.dart';
import 'package:test/test.dart';

void main() {
  test('passes when eligibility criteria reference existing screener questions', () {
    final q = BooleanQuestion.withId();

    final criterion = EligibilityCriterion.withId();
    final expr = ChoiceExpression();
    expr.target = q.id;
    criterion.condition = expr;

    final s = Study('id', 'user');
    s.questionnaire.questions = [q];
    s.eligibilityCriteria = [criterion];

    final r = validateEligibilityConsent(s, ValidationLevel.draft);
    expect(r.valid, isTrue);
  });

  test('fails when eligibility criterion target does not exist in questionnaire', () {
    final criterion = EligibilityCriterion.withId();
    final expr = ChoiceExpression();
    expr.target = 'non-existent-question-id';
    criterion.condition = expr;

    final s = Study('id', 'user');
    s.questionnaire = StudyUQuestionnaire(); // empty questionnaire
    s.eligibilityCriteria = [criterion];

    final r = validateEligibilityConsent(s, ValidationLevel.draft);
    expect(r.valid, isFalse);
    expect(r.errors.first.code, 'eligibility.target_question_missing');
  });
}
