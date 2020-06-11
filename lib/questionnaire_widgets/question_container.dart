import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/models/questionnaire/answer.dart';
import '../database/models/questionnaire/question.dart';
import '../database/models/questionnaire/questions/boolean_question.dart';
import '../database/models/questionnaire/questions/choice_question.dart';
import 'boolean_question_widget.dart';
import 'choice_question_widget.dart';
import 'question_widget.dart';

class QuestionContainer extends StatelessWidget {
  final Function(Answer, int) onDone;
  final Question question;
  final int index;

  const QuestionContainer({Key key, @required this.onDone, @required this.question, this.index}) : super(key: key);

  void _onDone(Answer answer) {
    onDone(answer, index);
  }

  QuestionWidget getQuestionBody() {
    switch (question.runtimeType) {
      case ChoiceQuestion:
        return ChoiceQuestionWidget(
          question: question as ChoiceQuestion,
          onDone: _onDone,
        );
      case BooleanQuestion:
        return BooleanQuestionWidget(
          question: question as BooleanQuestion,
          onDone: _onDone,
        );
      default:
        print('Question not supported!');
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionBody = getQuestionBody();

    var header = <Widget>[
      Text(
          question.prompt,
          style: Theme.of(context).textTheme.subtitle1
      ),
    ];
    if (questionBody.subtitle != null) {
      header.addAll([
        SizedBox(height: 8),
        Text(
            questionBody.subtitle,
            style: Theme.of(context).textTheme.caption
        ),
      ]);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChangeNotifierProvider<QuestionWidgetModel>(
          create: (context) => QuestionWidgetModel(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...header,
              SizedBox(height: 16),
              questionBody
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionWidgetModel extends ChangeNotifier {
  Answer _answer;

  Answer get answer => _answer;

  set answer(Answer answer) {
    _answer = answer;
    notifyListeners();
  }

}
