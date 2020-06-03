import 'package:research_package/model.dart';

import '../database/models/questionnaire/questions/multiple_choice_question.dart';
import '../database/models/questionnaire/questions/question.dart';
import 'multiple_choice_question_widget.dart';

class QuestionWidget extends RPQuestionStep {
  QuestionWidget(String identifier) : super(identifier);

  static RPQuestionStep buildFromQuestion(Question question) {
    switch (question.runtimeType) {
      case MultipleChoiceQuestion:
        return MultipleChoiceQuestionWidget.build(question as MultipleChoiceQuestion);
      default:
        print('Question not supported!');
        return null;
    }
  }

}