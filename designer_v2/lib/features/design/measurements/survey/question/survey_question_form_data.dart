import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_type.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

typedef SurveyQuestionFormDataFactory = SurveyQuestionFormData Function(Question question);

abstract class SurveyQuestionFormData {
  static Map<SurveyQuestionType,SurveyQuestionFormDataFactory> questionTypeFormDataFactories = {
    SurveyQuestionType.scale: (question) =>
        ScaleQuestionFormData.fromDomainModel(question),
    SurveyQuestionType.bool: (question) =>
        BoolQuestionFormData.fromDomainModel(question as BooleanQuestion),
    SurveyQuestionType.choice: (question) =>
        ChoiceQuestionFormData.fromDomainModel(question as ChoiceQuestion),
  };

  SurveyQuestionFormData({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    this.questionInfoText,
  });

  final QuestionID questionId;
  final String questionText;
  final String? questionInfoText;
  final SurveyQuestionType questionType;

  factory SurveyQuestionFormData.fromDomainModel(Question question) {
    final surveyQuestionType = SurveyQuestionType.of(question);
    if (!questionTypeFormDataFactories.containsKey(surveyQuestionType)) {
      throw Exception("Failed to create SurveyQuestionFormData for unknown "
          "SurveyQuestionType: $surveyQuestionType");
    }
    return questionTypeFormDataFactories[surveyQuestionType]!(question);
  }

  Question toQuestion();
  SurveyQuestionFormData copy();
}

class ChoiceQuestionFormData extends SurveyQuestionFormData {
  ChoiceQuestionFormData({
    required super.questionId,
    required super.questionText,
    required super.questionType,
    super.questionInfoText,
    this.isMultipleChoice = false,
    required this.answerOptions,
  });

  final bool isMultipleChoice;
  final List<FormControlOption> answerOptions;

  factory ChoiceQuestionFormData.fromDomainModel(ChoiceQuestion question) {
    return ChoiceQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.choice,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      isMultipleChoice: question.multiple,
      answerOptions: question.choices.map(
          (choice) => FormControlOption(choice.id, choice.text)).toList()
    );
  }

  @override
  Question toQuestion() {
    final question = ChoiceQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.multiple = isMultipleChoice;
    question.choices = answerOptions.map((option) {
      final choice =  Choice(option.value);
      choice.text = option.label;
      return choice;
    }).toList();
    return question;
  }

  @override
  SurveyQuestionFormData copy() {
    return ChoiceQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      isMultipleChoice: isMultipleChoice,
      answerOptions: answerOptions.map(
          (option) => FormControlOption(option.value, option.label)).toList(),
    );
  }
}

/*
BoolQuestionFormData
options: Option(id, label, value, validator?)
  validators: Any (qualify), None (disqualify)
 */
class BoolQuestionFormData extends SurveyQuestionFormData {
  BoolQuestionFormData({
    required super.questionId,
    required super.questionText,
    required super.questionType,
    super.questionInfoText,
  });

  final List<FormControlOption> answerOptions = [
    // Fixed list of options
    FormControlOption("yes", "Yes".hardcoded),
    FormControlOption("no", "No".hardcoded),
  ];

  factory BoolQuestionFormData.fromDomainModel(BooleanQuestion question) {
    return BoolQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.bool,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
    );
  }

  @override
  Question toQuestion() {
    final question = BooleanQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    return question;
  }

  @override
  BoolQuestionFormData copy() {
    return BoolQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
    );
  }
}

// TODO: placeholder (currently blocked waiting for designs)
class ScaleQuestionFormData extends SurveyQuestionFormData {
  ScaleQuestionFormData({
    required super.questionId,
    required super.questionText,
    required super.questionType,
    super.questionInfoText,
  });

  factory ScaleQuestionFormData.fromDomainModel(Question question) {
    return ScaleQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.scale,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
    );
  }

  @override
  Question toQuestion() {
    final question = AnnotatedScaleQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    // TODO: annotations
    return question;
  }

  @override
  SurveyQuestionFormData copy() {
    return ScaleQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
    );
  }
}
