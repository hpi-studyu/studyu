import 'package:json_annotation/json_annotation.dart';

import '../answer.dart';
import '../question.dart';

abstract class SliderQuestion extends Question {
  double minimum;
  double maximum;
  double initial;
  @JsonKey(nullable: true)
  double step;

  Answer<double> constructAnswer(double response) => Answer.forQuestion(this, response);
}
