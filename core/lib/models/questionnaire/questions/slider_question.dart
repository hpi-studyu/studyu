import 'package:json_annotation/json_annotation.dart';

import '../answer.dart';
import '../question.dart';

abstract class SliderQuestion extends Question<num> {
  double minimum;
  double maximum;
  double initial;
  @JsonKey(nullable: true)
  double step;

  SliderQuestion(String type) : super(type);

  SliderQuestion.designer(String type)
      : minimum = 0,
        maximum = 0,
        initial = 0,
        step = 1,
        super.designer(type);

  Answer<num> constructAnswer(double response) => Answer.forQuestion(this, response);
}
