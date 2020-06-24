import '../question.dart';

abstract class SliderQuestion extends Question {
  int minimum;
  int maximum;
  int step;
}
