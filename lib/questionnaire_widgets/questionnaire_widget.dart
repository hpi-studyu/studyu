import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database/models/questionnaire/answers/answer.dart';
import '../database/models/questionnaire/conditions/condition.dart';
import '../database/models/questionnaire/questions/question.dart';
import 'question_widget.dart';

class QuestionnaireWidget extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final List<Condition> conditions;
  final Function(bool, Map<int, Answer>) onQuestionnaireDone;

  const QuestionnaireWidget({Key key, this.title, @required this.questions, this.conditions, this.onQuestionnaireDone})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuestionnaireState();
}

class _QuestionnaireState extends State<QuestionnaireWidget> {
  final List<QuestionWidget> shownQuestions = <QuestionWidget>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final LinkedHashMap<int, Answer> _answers = LinkedHashMap<int, Answer>();
  int _nextQuestionIndex = 1;

  void _finishQuestionnaire() {
    var conditionResult = widget.conditions
        .every((condition) => condition.checkAnswer(_answers[condition.questionId]));
    //widget.onQuestionnaireDone(conditionResult, _answers);
    Navigator.of(context).pop([conditionResult, _answers]);
  }

  void _onQuestionDone(Answer answer, int index) {
    if (index < _nextQuestionIndex - 1) {
      while (shownQuestions.length > index + 1) {
        var end = shownQuestions.length - 1;
        var lastQuestion = shownQuestions.removeLast();
        _listKey.currentState.removeItem(end, (context, animation) => SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          child: lastQuestion,
        ));
        _answers.remove(lastQuestion.question.id);
      }
      _nextQuestionIndex = index + 1;
    }
    _answers.update(answer.id, (_) => answer, ifAbsent: () => answer);
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
