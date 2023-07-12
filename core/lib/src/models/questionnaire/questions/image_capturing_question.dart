import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';

part 'image_capturing_question.g.dart';

@JsonSerializable()
class ImageCapturingQuestion extends Question<ImageCapturingQuestion> {
  static const String questionType = 'ImageCapturingQuestion';

  ImageCapturingQuestion() : super(questionType);

  ImageCapturingQuestion.withId() : super.withId(questionType);

  factory ImageCapturingQuestion.fromJson(Map<String, dynamic> json) => _$ImageCapturingQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ImageCapturingQuestionToJson(this);

  // ignore: avoid_positional_boolean_parameters
  Answer<bool> constructAnswer(bool response) => Answer.forQuestion(this, response);
}
