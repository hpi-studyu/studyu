import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/body_parts.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';

part 'pain_question.g.dart';

@JsonSerializable()
class PainQuestion extends Question<BodyParts> {
  static const String questionType = 'pain';

  PainQuestion() : super(questionType);

  PainQuestion.withId() : super.withId(questionType);

  factory PainQuestion.fromJson(Map<String, dynamic> json) =>
      _$PainQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PainQuestionToJson(this);

  Answer<BodyParts> constructAnswer(BodyParts response) =>
      Answer.forQuestion(this, response);
}
