import 'package:research_package/model.dart';

import '../database/models/questionnaire/questions/multiple_choice_question.dart';
import 'question_widget.dart';

class MultipleChoiceQuestionWidget extends QuestionWidget {
  MultipleChoiceQuestionWidget(String identifier) : super(identifier);

  static RPQuestionStep build(MultipleChoiceQuestion question) {
    final choices = <RPChoice>[];
    for (var choice in question.choices) {
      final choiceStep = RPChoice.withParams(choice.value, choice.id);
      choices.add(choiceStep);
    }
    final answerFormat = RPChoiceAnswerFormat.withParams(
        question.multiple
            ? ChoiceAnswerStyle.MultipleChoice
            : ChoiceAnswerStyle.SingleChoice,
        choices);
    return RPQuestionStep.withAnswerFormat('${question.id}', question.question, answerFormat);
  }
  
}