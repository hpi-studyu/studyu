import 'package:flutter/rendering.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

typedef SurveyQuestionFormDataFactory = QuestionFormData Function(
    Question question, List<EligibilityCriterion> eligibilityCriteria);

abstract class QuestionFormData implements IFormData {
  static Map<SurveyQuestionType, SurveyQuestionFormDataFactory> questionTypeFormDataFactories = {
    SurveyQuestionType.scale: (question, eligibilityCriteria) {
      switch (question) {
        // First check for general scale which implements the other interfaces
        case ScaleQuestion scaleQuestion:
          return ScaleQuestionFormData.fromDomainModel(scaleQuestion, eligibilityCriteria);
        // Remain backward compatible with specialized scale types
        case AnnotatedScaleQuestion annotatedScaleQuestion:
          return ScaleQuestionFormData.fromDomainModel(
            ScaleQuestion.fromAnnotatedScaleQuestion(annotatedScaleQuestion),
            eligibilityCriteria,
          );
        case VisualAnalogueQuestion visualAnalogueQuestion:
          return ScaleQuestionFormData.fromDomainModel(
            ScaleQuestion.fromVisualAnalogueQuestion(visualAnalogueQuestion),
            eligibilityCriteria,
          );
      }
      return ScaleQuestionFormData.fromDomainModel(question as ScaleQuestion, eligibilityCriteria);
    },
    SurveyQuestionType.bool: (question, eligibilityCriteria) =>
        BoolQuestionFormData.fromDomainModel(question as BooleanQuestion, eligibilityCriteria),
    SurveyQuestionType.choice: (question, eligibilityCriteria) =>
        ChoiceQuestionFormData.fromDomainModel(question as ChoiceQuestion, eligibilityCriteria),
    SurveyQuestionType.image: (question, eligibilityCriteria) =>
        ImageQuestionFormData.fromDomainModel(question as ImageCapturingQuestion, eligibilityCriteria),
    SurveyQuestionType.audio: (question, eligibilityCriteria) =>
        AudioQuestionFormData.fromDomainModel(question as AudioRecordingQuestion, eligibilityCriteria),
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

  @override
  List<String> get responseOptions => answerOptions;

  factory ChoiceQuestionFormData.fromDomainModel(
    ChoiceQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = ChoiceQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.choice,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
      isMultipleChoice: question.multiple,
      answerOptions: question.choices.map((choice) => choice.text).toList(),
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = ChoiceQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    question.multiple = isMultipleChoice;
    question.choices = answerOptions.map(_buildChoiceForValue).toList();
    return question;
  }

  @override
  QuestionFormData copy() {
    final data = ChoiceQuestionFormData(
      questionId: const Uuid().v4(),
      // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
      isMultipleChoice: isMultipleChoice,
      answerOptions: [...answerOptions],
    );
    data.responseOptionsValidity = responseOptionsValidity;
    return data;
  }

  Choice _buildChoiceForValue(String value) {
    final choiceId = value.toKey();
    final choice = Choice(choiceId);
    choice.text = value;
    return choice;
  }

  @override
  Answer constructAnswerFor(responseOption) {
    final question = toQuestion() as ChoiceQuestion;
    final choice = _buildChoiceForValue(responseOption);
    return question.constructAnswer([choice]);
  }
}

class BoolQuestionFormData extends QuestionFormData {
  BoolQuestionFormData({
    required super.questionId,
    required super.questionText,
    required super.questionType,
    super.questionInfoText,
  });

  static Map<String, bool> get kResponseOptions => {
        tr.form_array_response_options_bool_yes: true,
        tr.form_array_response_options_bool_no: false,
      };

  @override
  List<String> get responseOptions => kResponseOptions.keys.toList();

  factory BoolQuestionFormData.fromDomainModel(
    BooleanQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = BoolQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.bool,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
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
    final data = BoolQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
    );
    data.responseOptionsValidity = responseOptionsValidity;
    return data;
  }

  @override
  Answer constructAnswerFor(responseOption) {
    final question = toQuestion() as BooleanQuestion;
    final value = kResponseOptions[responseOption] as bool;
    return question.constructAnswer(value);
  }
}

class ImageQuestionFormData extends QuestionFormData {
  ImageQuestionFormData({
    required super.questionId,
    required super.questionText,
    required super.questionType,
    super.questionInfoText,
  });

  static Map<String, String> get kResponseOptions => {tr.form_field_response_image: 'image'};

  @override
  List<String> get responseOptions => kResponseOptions.keys.toList();

  factory ImageQuestionFormData.fromDomainModel(
    ImageCapturingQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = ImageQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.image,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = ImageCapturingQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    return question;
  }

  @override
  ImageQuestionFormData copy() {
    final data = ImageQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
    );
    data.responseOptionsValidity = responseOptionsValidity;
    return data;
  }

  @override
  Answer constructAnswerFor(responseOption) {
    final question = toQuestion() as ImageCapturingQuestion;
    final value = kResponseOptions[responseOption] as String;
    return question.constructAnswer(value);
  }
}

class AudioQuestionFormData extends QuestionFormData {
  AudioQuestionFormData({
    required super.questionId,
    required super.questionText,
    required super.questionType,
    super.questionInfoText,
  });

  static Map<String, String> get kResponseOptions => {tr.form_field_response_audio: 'audio'};

  @override
  List<String> get responseOptions => kResponseOptions.keys.toList();

  factory AudioQuestionFormData.fromDomainModel(
    AudioRecordingQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = AudioQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.audio,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = AudioRecordingQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    return question;
  }

  @override
  AudioQuestionFormData copy() {
    final data = AudioQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
    );
    data.responseOptionsValidity = responseOptionsValidity;
    return data;
  }

  @override
  Answer constructAnswerFor(responseOption) {
    final question = toQuestion() as AudioRecordingQuestion;
    final value = kResponseOptions[responseOption] as String;
    return question.constructAnswer(value);
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
    this.initialValue,
    this.stepSize = 0,
    this.minColor,
    this.maxColor,
  }) : assert(midValues.length == midLabels.length, "midValues.length and midLabels.length must be equal");

  final double minValue;
  final double maxValue;
  final String? minLabel;
  final String? maxLabel;
  final List<double?> midValues;
  final List<String?> midLabels;
  final double stepSize;
  final double? initialValue;
  final Color? minColor;
  final Color? maxColor;

  @override
  List<double> get responseOptions => toQuestion().values;

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

  factory ScaleQuestionFormData.fromDomainModel(
    ScaleQuestion question,
    List<EligibilityCriterion> eligibilityCriteria,
  ) {
    final data = ScaleQuestionFormData(
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
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
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
    final data = ScaleQuestionFormData(
      questionId: const Uuid().v4(),
      // always regenerate id
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
    data.responseOptionsValidity = responseOptionsValidity;
    return data;
  }

  @override
  Answer constructAnswerFor(responseOption) {
    final question = toQuestion();
    return question.constructAnswer(responseOption as double);
  }
}
