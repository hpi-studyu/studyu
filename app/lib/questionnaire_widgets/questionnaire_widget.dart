import 'package:flutter/material.dart';
import 'package:nof1_models/models/models.dart';

import 'question_container.dart';

typedef StateHandler = void Function(QuestionnaireState);

class QuestionnaireWidget extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final StateHandler onChange;
  final StateHandler onComplete;

  const QuestionnaireWidget(this.questions, {this.title, this.onComplete, this.onChange, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuestionnaireWidgetState();
}

class _QuestionnaireWidgetState extends State<QuestionnaireWidget> {
  final List<QuestionContainer> shownQuestions = <QuestionContainer>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final QuestionnaireState qs = QuestionnaireState();
  int _nextQuestionIndex = 1;

  void _finishQuestionnaire() {
    if (widget.onComplete != null) widget.onComplete(qs);
  }

  void _invalidateDownstreamAnswers(int index) {
    if (index < _nextQuestionIndex - 1) {
      while (shownQuestions.length > index + 1) {
        final end = shownQuestions.length - 1;
        final lastQuestion = shownQuestions.removeLast();
        _listKey.currentState.removeItem(
            end,
            (context, animation) => SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.vertical,
                  child: lastQuestion,
                ));
        qs.answers.remove(lastQuestion.question.id);
      }
    }
  }

  void _insertQuestion(int index) {
    shownQuestions.add(QuestionContainer(
      key: UniqueKey(),
      question: widget.questions[index],
      onDone: _onQuestionDone,
      index: index,
    ));
  }

  void _onQuestionDone(Answer answer, int index) {
    _invalidateDownstreamAnswers(index);
    _nextQuestionIndex = index + 1;
    qs.answers[answer.question] = answer;
    if (widget.onChange != null) widget.onChange(qs);
    if (widget.questions.length > _nextQuestionIndex) {
      _insertQuestion(_nextQuestionIndex);
      _listKey.currentState.insertItem(_nextQuestionIndex, duration: Duration(milliseconds: 300));
      _nextQuestionIndex++;
    } else {
      _finishQuestionnaire();
    }
  }

  @override
  void initState() {
    super.initState();
    _insertQuestion(0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: shownQuestions.length,
      itemBuilder: (context, index, animation) {
        return SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          child: shownQuestions[index],
        );
      },
    );
  }
}
