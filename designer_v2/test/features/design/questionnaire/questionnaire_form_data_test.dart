import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';

import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  group('QuestionnaireFormData', () {
    test('does not create eligibility criteria for free text questions', () {
      final formData = QuestionnaireFormData(
        questionsData: [
          FreeTextQuestionFormData(
            questionId: 'free-text',
            questionText: 'Free text',
            questionType: SurveyQuestionType.freeText,
            textLengthRange: [0, 500],
            textType: FreeTextQuestionType.any,
            textTypeExpression: null,
          ),
        ],
      );

      expect(formData.toEligibilityCriteria(), isEmpty);
    });

    test('keeps eligibility criteria for questions with response options', () {
      final includedChoice = Choice.withId()
        ..id = 'included-choice'
        ..text = 'Included';
      final excludedChoice = Choice.withId()
        ..id = 'excluded-choice'
        ..text = 'Excluded';

      final formData = QuestionnaireFormData(
        questionsData: [
          ChoiceQuestionFormData(
              questionId: 'choice',
              questionText: 'Choice',
              questionType: SurveyQuestionType.choice,
              answerOptions: [includedChoice, excludedChoice],
            )
            ..responseOptionsValidity = {
              includedChoice: true,
              excludedChoice: false,
            },
        ],
      );

      final criteria = formData.toEligibilityCriteria();
      final expression = criteria.single.condition;

      expect(expression, isA<ChoiceExpression>());
      expect(expression.toJson(), containsPair('target', 'choice'));
      expect(expression.toJson(), containsPair('choices', ['included-choice']));
    });
  });

  group('MedicationQuestionFormData', () {
    test('converts a measurement medication question from its domain model', () {
      final question = MedicationQuestion()
        ..id = 'medication-question'
        ..prompt = 'What medication did you take?'
        ..rationale = 'Include the quantity.';

      final formData = QuestionFormData.fromDomainModel(question, []);

      expect(formData, isA<MedicationQuestionFormData>());
      expect(formData.questionType, SurveyQuestionType.medication);
      expect(formData.questionId, question.id);
      expect(formData.questionText, question.prompt);
      expect(formData.questionInfoText, question.rationale);
    });

    test('round-trips prompt, rationale, and conditional', () {
      final conditional = QuestionConditional<MedicationAnswer>.withCondition(
        CompositeExpression(logicType: LogicType.and, expressions: []),
      );
      final formData = MedicationQuestionFormData(
        questionId: 'medication-question',
        questionText: 'What medication did you take?',
        questionType: SurveyQuestionType.medication,
        questionInfoText: 'Include the quantity.',
        conditional: conditional,
      );

      final question = formData.toQuestion();

      expect(question, isA<MedicationQuestion>());
      expect(question.id, formData.questionId);
      expect(question.prompt, formData.questionText);
      expect(question.rationale, formData.questionInfoText);
      expect(question.conditional?.condition.toJson(), conditional.condition.toJson());
    });

    test('duplicates without eligibility semantics', () {
      final formData = MedicationQuestionFormData(
        questionId: 'medication-question',
        questionText: 'Medication',
        questionType: SurveyQuestionType.medication,
      );

      final duplicate = formData.copy();

      expect(duplicate.questionId, isNot(formData.questionId));
      expect(duplicate.questionText, 'Medication (Copy)');
      expect(formData.toEligibilityCriterion(), isNull);
    });

    test('is not available in enrollment screener question types', () {
      final viewModel = ScreenerQuestionFormViewModel();

      expect(
        viewModel.questionTypeControlOptions.map((option) => option.value),
        isNot(contains(SurveyQuestionType.medication)),
      );
    });
  });
}
