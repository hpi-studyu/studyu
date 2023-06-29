import 'package:flutter/widgets.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_type.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

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
