import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/models/questionnaire/answers/answer.dart';
import '../database/models/questionnaire/questions/multiple_choice_question.dart';
import '../database/models/questionnaire/questions/question.dart';
import 'multiple_choice_question_widget.dart';

class QuestionWidget extends StatelessWidget {
  final Function(Answer, int) onDone;
  final Question question;
  final int index;

  const QuestionWidget({Key key, @required this.onDone, @required this.question, this.index}) : super(key: key);

  void _onDone(Answer answer) {
    onDone(answer, index);
  }

  Widget getQuestionBody() {
    switch (question.runtimeType) {
      case MultipleChoiceQuestion:
        return MultipleChoiceQuestionWidget(
          question: question as MultipleChoiceQuestion,
          onDone: _onDone,
        );
      default:
        print('Question not supported!');
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChangeNotifierProvider<QuestionWidgetModel>(
          create: (context) => QuestionWidgetModel(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(question.question),
              SizedBox(
                height: 5,
              ),
              getQuestionBody(),
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
