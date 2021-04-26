import 'package:json_annotation/json_annotation.dart';

import '../question_conditional.dart';
import 'slider_question.dart';

part 'visual_analogue_question.g.dart';

@JsonSerializable()
class VisualAnalogueQuestion extends SliderQuestion {
  static const String questionType = 'visualAnalogue';

  int minimumColor = 0xFFFFFFFF;
  int maximumColor = 0xFFFFFFFF;

  String minimumAnnotation = '';
  String maximumAnnotation = '';

  VisualAnalogueQuestion() : super(questionType);

  VisualAnalogueQuestion.withId() : super.withId(questionType);

  factory VisualAnalogueQuestion.fromJson(Map<String, dynamic> json) => _$VisualAnalogueQuestionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VisualAnalogueQuestionToJson(this);
}
