import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'nutrition_question.g.dart';

@JsonSerializable()
class NutritionQuestion extends Question<DailyRecall> {
  static const String questionType = 'nutrition';

  NutritionQuestion() : super(questionType);

  NutritionQuestion.withId() : super.withId(questionType);

  factory NutritionQuestion.fromJson(Map<String, dynamic> json) =>
      _$NutritionQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NutritionQuestionToJson(this);

  @override
  Answer<DailyRecall> constructAnswer(DailyRecall response) {
    return Answer.forQuestion(this, response);
  }
}
