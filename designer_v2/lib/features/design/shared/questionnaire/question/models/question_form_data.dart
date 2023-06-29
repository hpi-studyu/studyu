import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/bool_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/choice_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/scale_question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

typedef SurveyQuestionFormDataFactory = QuestionFormData Function(
    Question question, List<EligibilityCriterion> eligibilityCriteria);

abstract class QuestionFormData implements IFormData {
  static Map<SurveyQuestionType, SurveyQuestionFormDataFactory> questionTypeFormDataFactories = {
    SurveyQuestionType.scale: (question, eligibilityCriteria) {
      switch (question.runtimeType) {
        // First check for general scale which implements the other interfaces
        case ScaleQuestion:
          return ScaleQuestionFormData.fromDomainModel(question as ScaleQuestion, eligibilityCriteria);
        // Remain backward compatible with specialized scale types
        case AnnotatedScaleQuestion:
          return ScaleQuestionFormData.fromDomainModel(
            ScaleQuestion.fromAnnotatedScaleQuestion(question as AnnotatedScaleQuestion),
            eligibilityCriteria,
          );
        case VisualAnalogueQuestion:
          return ScaleQuestionFormData.fromDomainModel(
            ScaleQuestion.fromVisualAnalogueQuestion(question as VisualAnalogueQuestion),
            eligibilityCriteria,
          );
      }
      return ScaleQuestionFormData.fromDomainModel(question as ScaleQuestion, eligibilityCriteria);
    },
    SurveyQuestionType.bool: (question, eligibilityCriteria) =>
        BoolQuestionFormData.fromDomainModel(question as BooleanQuestion, eligibilityCriteria),
    SurveyQuestionType.choice: (question, eligibilityCriteria) =>
        ChoiceQuestionFormData.fromDomainModel(question as ChoiceQuestion, eligibilityCriteria),
  };

  QuestionFormData({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    this.questionInfoText,
  });

  final QuestionID questionId;
  final String questionText;
  final String? questionInfoText;
  final SurveyQuestionType questionType;

  /// Mapping from response option => qualifying/disqualifying
  late final Map<dynamic, bool> responseOptionsValidity;

  List<dynamic> get responseOptions; // subclass responsibility

  @override
  String get id => questionId;

  factory QuestionFormData.fromDomainModel(
    Question question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final surveyQuestionType = SurveyQuestionType.of(question);
    if (!questionTypeFormDataFactories.containsKey(surveyQuestionType)) {
      throw Exception("Failed to create SurveyQuestionFormData for unknown "
          "SurveyQuestionType: $surveyQuestionType");
    }
    return questionTypeFormDataFactories[surveyQuestionType]!(question, eligibilityCriteria);
  }

  Question toQuestion(); // subclass responsibility

  EligibilityCriterion toEligibilityCriterion() {
    final criterion = EligibilityCriterion.withId();
    final expression = ChoiceExpression()..target = questionId;
    // Screener conditions are implemented as disqualifying by default in the
    // app (as of now), so we need to generate conditions for the qualifying
    // response options here
    for (final responseOption in responseOptions) {
      final isQualifying = responseOptionsValidity[responseOption] ?? true;
      if (isQualifying) {
        final answer = constructAnswerFor(responseOption);
        final selectedValue = answer.response;
        if (selectedValue is List) {
          expression.choices.addAll(selectedValue);
        } else {
          expression.choices.add(selectedValue);
        }
      }
    }
    criterion.condition = expression;
    return criterion;
  }

  Answer constructAnswerFor(dynamic responseOption);

  /// Determines the [responseOptionsValidity] in terms of qualify/disqualify
  /// by evaluating the given criteria for each response option on a new
  /// [QuestionnaireState] where the option is selected
  setResponseOptionsValidityFrom(List<EligibilityCriterion> eligibilityCriteria) {
    final Map<dynamic, bool> result = {};

    for (final responseOption in responseOptions) {
      final questionnaireState = QuestionnaireState();
      final answer = constructAnswerFor(responseOption);
      questionnaireState.answers[id] = answer;

      // Options are implemented as disqualifying by default in the app
      // (as of now) if no criterion evaluates to true
      bool responseOptionValidity = false;
      for (final criterion in eligibilityCriteria) {
        responseOptionValidity = responseOptionValidity || (criterion.condition.evaluate(questionnaireState) ?? false);
      }
      result[responseOption] = responseOptionValidity;
    }

    responseOptionsValidity = result;
  }

  @override
  QuestionFormData copy(); // subclass responsibility
}
