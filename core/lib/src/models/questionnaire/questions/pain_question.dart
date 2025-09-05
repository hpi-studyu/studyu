import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';

part 'pain_question.g.dart';

@JsonSerializable()
class PainQuestion extends Question<List<BodyPart>> {
  static const String questionType = 'pain';

  PainQuestion() : super(questionType);

  PainQuestion.withId() : super.withId(questionType);

  factory PainQuestion.fromJson(Map<String, dynamic> json) =>
      _$PainQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PainQuestionToJson(this);

  Answer<List<BodyPart>> constructAnswer(Body response) {
    return Answer.forQuestion(this, response.painfulParts);
  }
}
