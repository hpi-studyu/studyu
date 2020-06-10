import 'package:flutter/material.dart';

import '../database/models/eligibility/eligibility_criterion.dart';
import '../database/models/questionnaire/answer.dart';
import '../database/models/questionnaire/question.dart';
import '../database/models/questionnaire/questionnaire_state.dart';
import 'question_widget.dart';

class QuestionnaireScreenArguments {
  final Key key;
  final String title;
  final List<Question> questions;
  final List<EligibilityCriterion> criteria;

  QuestionnaireScreenArguments({this.key, this.title, @required this.questions, this.criteria});
}

class QuestionnaireScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final List<EligibilityCriterion> criteria;

  const QuestionnaireScreen({Key key, this.title, @required this.questions, this.criteria}) : super(key: key);

  factory QuestionnaireScreen.fromRouteArgs(QuestionnaireScreenArguments args) => QuestionnaireScreen(
    key: args.key,
    title: args.title,
    questions: args.questions,
    criteria: args.criteria,
  );

  @override
  State<StatefulWidget> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final List<QuestionWidget> shownQuestions = <QuestionWidget>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final QuestionnaireState qs = QuestionnaireState();
  int _nextQuestionIndex = 1;

  void _finishQuestionnaire() {
    var conditionResult = widget.criteria?.every((criterion) => criterion.isSatisfied(qs)) ?? true;
    Navigator.of(context).pop([conditionResult, qs]);
  }

  void _onQuestionDone(Answer answer, int index) {
    if (index < _nextQuestionIndex - 1) {
      while (shownQuestions.length > index + 1) {
        var end = shownQuestions.length - 1;
        var lastQuestion = shownQuestions.removeLast();
        _listKey.currentState.removeItem(
            end,
            (context, animation) => SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.vertical,
                  child: lastQuestion,
                ));
        qs.answers.remove(lastQuestion.question.id);
      }
      _nextQuestionIndex = index + 1;
    }
    qs.answers[answer.question] = answer;
    if (widget.questions.length > _nextQuestionIndex) {
      shownQuestions.add(QuestionWidget(
        key: UniqueKey(),
        question: widget.questions[_nextQuestionIndex],
        onDone: _onQuestionDone,
        index: _nextQuestionIndex,
      ));
      _listKey.currentState.insertItem(_nextQuestionIndex, duration: Duration(milliseconds: 300));
      _nextQuestionIndex++;
    } else {
      _finishQuestionnaire();
    }
  }

  @override
  void initState() {
    shownQuestions.add(QuestionWidget(
      key: UniqueKey(),
      question: widget.questions[0],
      onDone: _onQuestionDone,
      index: 0,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: shownQuestions.length,
        itemBuilder: (context, index, animation) {
          return SizeTransition(
            sizeFactor: animation,
            axis: Axis.vertical,
            child: shownQuestions[index],
          );
        },
      ),
    );
  }
}
