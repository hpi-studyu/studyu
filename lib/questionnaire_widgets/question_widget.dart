import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/models/questionnaire/answers/answer.dart';
import '../database/models/questionnaire/questions/multiple_choice_question.dart';
import '../database/models/questionnaire/questions/question.dart';
import 'multiple_choice_question_widget.dart';

class QuestionWidget extends StatelessWidget {
  final Function(Answer) onDone;
  final Question question;

  const QuestionWidget({Key key, @required this.onDone, @required this.question}) : super(key: key);

  Widget getQuestionBody() {
    switch (question.runtimeType) {
      case MultipleChoiceQuestion:
        return MultipleChoiceQuestionWidget(
          question: question as MultipleChoiceQuestion,
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
        child: Provider<QuestionWidgetModel>(
          create: (context) => QuestionWidgetModel(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(question.question),
              Selector<QuestionWidgetModel, String>(
                builder: (context, data, child) => Text(
                  data,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                selector: (context, model) => model.additionalDescription,
              ),
              SizedBox(
                height: 5,
              ),
              getQuestionBody(),
              SizedBox(
                height: 5,
              ),
              Selector<QuestionWidgetModel, Answer>(
                builder: (context, data, child) => RaisedButton(
                  onPressed: data != null ? onDone(data) : null,
                  //TODO translate
                  child: Text('Next'),
                ),
                selector: (context, model) => model.answer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionWidgetModel extends ChangeNotifier {
  Answer answer;

  String additionalDescription = '';
}
