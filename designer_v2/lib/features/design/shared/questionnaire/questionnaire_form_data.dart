import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

class QuestionnaireFormData implements IFormData {
  QuestionnaireFormData({this.questionsData});

  final List<QuestionFormData>? questionsData;

  factory QuestionnaireFormData.fromDomainModel(
    StudyUQuestionnaire questionnaire,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    return QuestionnaireFormData(
      questionsData: questionnaire.questions
          .map(
            (question) => QuestionFormData.fromDomainModel(
              question,
              // Collect all eligibility criteria for this question
              eligibilityCriteria
                  .where(
                    (c) => _expressionTargetsQuestion(c.condition, question.id),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  static bool _expressionTargetsQuestion(Expression expression, String questionId) {
    if (expression is ValueExpression) {
      return expression.target == questionId;
    } else if (expression is NotExpression) {
      return _expressionTargetsQuestion(expression.expression, questionId);
    } else if (expression is CompositeExpression) {
      return expression.expressions.any((expr) => _expressionTargetsQuestion(expr, questionId));
    }
    return false;
  }

  StudyUQuestionnaire toQuestionnaire() {
    final questionnaire = StudyUQuestionnaire();
    questionnaire.questions = (questionsData != null)
        ? questionsData!.map((formData) => formData.toQuestion()).toList()
        : [];
    return questionnaire;
  }

  List<EligibilityCriterion> toEligibilityCriteria() {
    return questionsData?.map((q) => q.toEligibilityCriterion()).toList() ?? [];
  }

  @override
  QuestionnaireFormData copy() {
    return QuestionnaireFormData(
      questionsData: questionsData?.map((formData) => formData.copy()).toList(),
    );
  }

  @override
  FormDataID get id => throw UnimplementedError(); // not available
}
