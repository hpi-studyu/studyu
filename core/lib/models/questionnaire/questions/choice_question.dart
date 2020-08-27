import 'package:json_annotation/json_annotation.dart';

import '../answer.dart';
import '../question.dart';
import '../question_conditional.dart';

part 'choice_question.g.dart';

@JsonSerializable()
class ChoiceQuestion extends Question<List<String>> {
  static String questionType = 'choice';

  bool multiple;
  List<Choice> choices;

  ChoiceQuestion() : super(questionType);

  ChoiceQuestion.designer()
      : multiple = false,
        choices = [],
        super.designer(questionType);

  factory ChoiceQuestion.fromJson(Map<String, dynamic> json) => _$ChoiceQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ChoiceQuestionToJson(this);

  Answer<List<String>> constructAnswer(List<Choice> selected) =>
      Answer.forQuestion(this, selected.map((choice) => choice.id).toList());
}

@JsonSerializable()
class Choice {
  String id;
  String text;

  Choice();

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChoiceToJson(this);

  @override
  String toString() => toJson().toString();
}
