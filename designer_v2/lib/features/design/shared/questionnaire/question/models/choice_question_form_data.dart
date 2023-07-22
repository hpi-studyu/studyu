import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class ChoiceQuestionFormData extends QuestionFormData {
  ChoiceQuestionFormData({
    required super.questionId,
    required super.questionText,
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
  ChoiceQuestionFormData copy() {
    final data = ChoiceQuestionFormData(
      // always regenerate id
      questionId: const Uuid().v4(),
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
