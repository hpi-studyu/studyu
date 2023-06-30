import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/models/question_form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class BoolQuestionFormData extends QuestionFormData {
  BoolQuestionFormData({
    required super.questionId,
    required super.questionText,
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
