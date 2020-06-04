import 'package:flutter/material.dart';

import '../database/models/questionnaire/answers/answer.dart';
import '../database/models/questionnaire/questions/multiple_choice_question.dart';
import '../database/models/questionnaire/questions/question.dart';
import 'multiple_choice_question_widget.dart';

abstract class QuestionWidget extends StatefulWidget {

  final Function(Answer) onDone;
  final Question question;

  const QuestionWidget({Key key, @required this.onDone, @required this.question}) : super(key: key);

  factory QuestionWidget.generate({Key key, @required Function(Answer) onDone, @required Question question}) {
    switch (question.runtimeType) {
      case MultipleChoiceQuestion:
        return MultipleChoiceQuestionWidget(key, question as MultipleChoiceQuestion);
      default:
        print('Question not supported!');
        return null;
    }
  }

  Widget getCompleteQuestion(Widget questionSpecificBody) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(question.question),
            SizedBox(height: 5,),
            questionSpecificBody,
          ],
        ),
      ),
    );
  }

}