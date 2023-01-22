import '../answer.dart';
import '../question.dart';

abstract class SliderQuestion extends Question<num> {
  double minimum = 0;
  double maximum = 0;
  double initial = 0;
  double step = 1;

  SliderQuestion(super.type);

  SliderQuestion.withId(super.type) : super.withId();

  Answer<num> constructAnswer(double response) => Answer.forQuestion(this, response);
}
