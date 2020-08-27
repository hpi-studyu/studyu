import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

import '../question_conditional.dart';
import 'slider_question.dart';

part 'visual_analogue_question.g.dart';

@JsonSerializable()
class VisualAnalogueQuestion extends SliderQuestion {
  static const String questionType = 'visualAnalogue';

  @JsonKey(fromJson: parseColor, toJson: colorToJson)
  Color minimumColor;
  @JsonKey(fromJson: parseColor, toJson: colorToJson)
  Color maximumColor;

  String minimumAnnotation;
  String maximumAnnotation;

  VisualAnalogueQuestion() : super(questionType);

  VisualAnalogueQuestion.designer()
      : this.minimumColor = Color(0xFFFFFFFF),
        this.maximumColor = Color(0xFFFFFFFF),
        super.designer(questionType);

  factory VisualAnalogueQuestion.fromJson(Map<String, dynamic> json) => _$VisualAnalogueQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$VisualAnalogueQuestionToJson(this);

  static Color parseColor(String colorString) => Color(int.parse('ff${colorString.substring(1)}', radix: 16));
  static String colorToJson(Color color) => '#${color.value.toRadixString(16).padLeft(8, '0').substring(2, 8)}';
}
