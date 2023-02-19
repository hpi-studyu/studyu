import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:studyu_core/core.dart';

import 'question_container.dart';

typedef StateHandler = void Function(QuestionnaireState);
typedef ContinuationPredicate = bool Function(QuestionnaireState);

class QuestionnaireWidget extends StatefulWidget {
  final String title;
  final String header;
  final String footer;
  final List<Question> questions;
  final StateHandler onChange;
  final StateHandler onComplete;
  final ContinuationPredicate shouldContinue;

  const QuestionnaireWidget(
    this.questions, {
    this.title,
    this.header,
    this.footer,
    this.onComplete,
    this.onChange,
    this.shouldContinue,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuestionnaireWidgetState();
}

class _QuestionnaireWidgetState extends State<QuestionnaireWidget> {
  final List<QuestionContainer> shownQuestions = <QuestionContainer>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();

  final QuestionnaireState qs = QuestionnaireState();
  int _nextQuestionIndex = 1;

  void _finishQuestionnaire(QuestionnaireState result) => widget.onComplete?.call(result);

  // if question with lower index than current question is answered, remove all downstream answers
  void _invalidateDownstreamAnswers(int index) {
    if (index < shownQuestions.length - 1) {
      final startIndex = widget.questions.indexWhere((question) => question.id == shownQuestions[index].question.id);
      widget.questions.skip(startIndex + 1).forEach((question) => qs.answers.remove(question.id));
      while (index + 1 < shownQuestions.length) {
        final end = shownQuestions.length;
        final lastQuestion = shownQuestions.removeLast();
        _listKey.currentState.removeItem(
          end,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: lastQuestion,
          ),
        );
      }
    }
  }

  void _insertQuestion(Question question) {
    shownQuestions.add(
      QuestionContainer(
        key: UniqueKey(),
        question: question,
        onDone: _onQuestionDone,
        index: shownQuestions.length,
      ),
    );
  }

  void _onQuestionDone(Answer answer, int index) {
    _invalidateDownstreamAnswers(index);
    _nextQuestionIndex = widget.questions.indexWhere((question) => question.id == answer.question) + 1;
    qs.answers[answer.question] = answer;
    widget.onChange?.call(qs);

    // check if index of the next question is in range
    if (widget.questions.length > _nextQuestionIndex) {
      // we still have questions left

      if (!(widget.shouldContinue?.call(qs) ?? true)) return;

      // check for conditional questions
      if (!widget.questions[_nextQuestionIndex].shouldBeShown(qs)) {
        _onQuestionDone(widget.questions[_nextQuestionIndex].getDefaultAnswer(), shownQuestions.length);
        return;
      }
      _insertQuestion(widget.questions[_nextQuestionIndex]);
      _listKey.currentState.insertItem(shownQuestions.length - 1, duration: const Duration(milliseconds: 300));
      _nextQuestionIndex++;
    } else {
      // we ran out of questions
      _finishQuestionnaire(qs);
    }

    // Scroll to bottom
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _insertQuestion(widget.questions.first);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      controller: _scrollController,
      initialItemCount: shownQuestions.length + 1,
      itemBuilder: (context, index, animation) {
        if (index == 0) {
          return widget.header != null && widget.header.isNotEmpty ? TextBox(widget.header) : Container();
        }
        index -= 1;
        if (index == shownQuestions.length) {
          return widget.footer != null && widget.footer.isNotEmpty ? TextBox(widget.footer) : Container();
        }
        if (index > shownQuestions.length - 1) {
          index -= 1;
        }
        if (index > shownQuestions.length) {
          return Container();
        }
        return shownQuestions[index];
      },
    );
  }
}

class TextBox extends StatelessWidget {
  final String text;

  const TextBox(this.text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
          ],
        ),
      ),
    );
  }
}
