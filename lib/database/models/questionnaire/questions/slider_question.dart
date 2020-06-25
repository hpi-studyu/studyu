import '../answer.dart';
import '../question.dart';

abstract class SliderQuestion extends Question {
  int minimum;
  int maximum;
  int step;

  Answer<int> constructAnswer(int response) => Answer.forQuestion(this, response);
}
