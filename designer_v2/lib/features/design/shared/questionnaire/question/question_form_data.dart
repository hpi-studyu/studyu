import 'package:flutter/rendering.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/utils/color.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

typedef SurveyQuestionFormDataFactory = QuestionFormData Function(
    Question question);

abstract class QuestionFormData implements IFormData {
  static Map<SurveyQuestionType, SurveyQuestionFormDataFactory>
      questionTypeFormDataFactories = {
    SurveyQuestionType.scale: (question) {
      switch (question.runtimeType) {
        // First check for general scale which implements the other interfaces
        case ScaleQuestion:
          return ScaleQuestionFormData.fromDomainModel(
              question as ScaleQuestion);
        // Remain backward compatible with specialized scale types
        case AnnotatedScaleQuestion:
          return ScaleQuestionFormData.fromDomainModel(
            ScaleQuestion.fromAnnotatedScaleQuestion(
                question as AnnotatedScaleQuestion),
          );
        case VisualAnalogueQuestion:
          return ScaleQuestionFormData.fromDomainModel(
            ScaleQuestion.fromVisualAnalogueQuestion(
                question as VisualAnalogueQuestion),
          );
      }
      return ScaleQuestionFormData.fromDomainModel(question as ScaleQuestion);
    },
    SurveyQuestionType.bool: (question) =>
        BoolQuestionFormData.fromDomainModel(question as BooleanQuestion),
    SurveyQuestionType.choice: (question) =>
        ChoiceQuestionFormData.fromDomainModel(question as ChoiceQuestion),
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

  // TODO final EligibilityCriterion? eligibilityCriterion;

  @override
  String get id => questionId;

  factory QuestionFormData.fromDomainModel(Question question) {
    final surveyQuestionType = SurveyQuestionType.of(question);
    if (!questionTypeFormDataFactories.containsKey(surveyQuestionType)) {
      throw Exception("Failed to create SurveyQuestionFormData for unknown "
          "SurveyQuestionType: $surveyQuestionType");
    }
    return questionTypeFormDataFactories[surveyQuestionType]!(question);
  }

  Question toQuestion(); // subclass responsibility

  @override
  QuestionFormData copy(); // subclass responsibility
}

class ChoiceQuestionFormData extends QuestionFormData {
  ChoiceQuestionFormData({
    required super.questionId,
    required super.questionText,
    required super.questionType,
    super.questionInfoText,
    this.isMultipleChoice = false,
    required this.answerOptions,
  });

  final bool isMultipleChoice;
  final List<String> answerOptions;

  factory ChoiceQuestionFormData.fromDomainModel(ChoiceQuestion question) {
    return ChoiceQuestionFormData(
        questionId: question.id,
        questionType: SurveyQuestionType.choice,
        questionText: question.prompt ?? '',
        questionInfoText: question.rationale ?? '',
        isMultipleChoice: question.multiple,
        answerOptions: question.choices.map((choice) => choice.text).toList());
  }

  @override
  Question toQuestion() {
    final question = ChoiceQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.multiple = isMultipleChoice;
    question.choices = answerOptions.map((value) {
      final choiceId = value.toKey();
      final choice = Choice(choiceId);
      choice.text = value;
      return choice;
    }).toList();
    return question;
  }

  @override
  QuestionFormData copy() {
    return ChoiceQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      isMultipleChoice: isMultipleChoice,
      answerOptions: [...answerOptions],
    );
  }
}

/*
BoolQuestionFormData
options: Option(id, label, value, validator?)
  validators: Any (qualify), None (disqualify)
 */
class BoolQuestionFormData extends QuestionFormData {
  BoolQuestionFormData({
    required super.questionId,
    required super.questionText,
    required super.questionType,
    super.questionInfoText,
  });

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

class ScaleQuestionFormData extends QuestionFormData {
  ScaleQuestionFormData({
    required super.questionId,
    required super.questionText,
    required super.questionType,
    super.questionInfoText,
    required this.minValue,
    this.minLabel,
    required this.maxValue,
    this.maxLabel,
    required this.midValues,
    required this.midLabels,
    this.initialValue = 1,
    this.stepSize = 1,
    this.minColor,
    this.maxColor,
  }) : assert(midValues.length == midLabels.length,
            "midValues.length and midLabels.length must be equal");

  final double minValue;
  final double maxValue;
  final String? minLabel;
  final String? maxLabel;
  final List<double?> midValues;
  final List<String?> midLabels;
  final double stepSize;
  final double initialValue;
  final Color? minColor;
  final Color? maxColor;

  List<Annotation> get midAnnotations {
    final List<Annotation> midAnnotations = [];
    for (int i = 0; i < midValues.length; i++) {
      final value = midValues[i];
      final label = midLabels[i];
      if (value != null && label != null && label.isNotEmpty) {
        final midAnnotation = Annotation()
          ..value = value.toInt()
          ..annotation = label;
        midAnnotations.add(midAnnotation);
      }
    }
    return midAnnotations;
  }

  factory ScaleQuestionFormData.fromDomainModel(ScaleQuestion question) {
    return ScaleQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.scale,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      maxValue: question.maximum,
      minValue: question.minimum,
      minLabel: question.minLabel,
      maxLabel: question.maxLabel,
      midValues: question.midValues,
      midLabels: question.midLabels,
      stepSize: question.step,
      initialValue: question.initial,
      minColor: (question.minColor != null) ? Color(question.minColor!) : null,
      maxColor: (question.maxColor != null) ? Color(question.maxColor!) : null,
    );
  }

  @override
  ScaleQuestion toQuestion() {
    final question = ScaleQuestion()
      ..id = questionId
      ..prompt = questionText
      ..rationale = questionInfoText
      ..minimum = minValue
      ..maximum = maxValue
      ..step = stepSize
      ..initial = initialValue
      ..minColor = minColor?.value
      ..maxColor = maxColor?.value
      ..midAnnotations = midAnnotations;

    if (minLabel != null) {
      question.minLabel = minLabel!;
    }
    if (maxLabel != null) {
      question.maxLabel = maxLabel!;
    }
    return question;
  }

  @override
  QuestionFormData copy() {
    return ScaleQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      minValue: minValue,
      minLabel: minLabel,
      maxValue: maxValue,
      maxLabel: maxLabel,
      stepSize: stepSize,
      initialValue: initialValue,
      minColor: minColor,
      maxColor: maxColor,
      midLabels: midLabels,
      midValues: midValues,
    );
  }
}
