import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/questionnaire/question_container.dart';
import 'package:studyu_core/core.dart';

typedef StateHandler = void Function(QuestionnaireState?);
typedef ContinuationPredicate = bool Function(QuestionnaireState);

class QuestionnaireWidget extends StatefulWidget {
  final String? title;
  final String? header;
  final String? footer;
  final List<Question> questions;
  final String? taskId;
  final StateHandler? onComplete;
  final ContinuationPredicate? shouldContinue;

  const QuestionnaireWidget(
    this.questions, {
    this.taskId,
    this.title,
    this.header,
    this.footer,
    this.onComplete,
    this.shouldContinue,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _QuestionnaireWidgetState();
}

class _QuestionnaireWidgetState extends State<QuestionnaireWidget> {
  final List<QuestionContainer> shownQuestions = <QuestionContainer>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();

  final QuestionnaireState qs = QuestionnaireState();

  void _finishQuestionnaire(QuestionnaireState? result) =>
      widget.onComplete?.call(result);

  void _addQuestionToList(Question question) {
    shownQuestions.add(
      QuestionContainer(
        key: UniqueKey(),
        question: question,
        onDone: _onQuestionDone,
        index: shownQuestions.length,
        taskId: widget.taskId,
      ),
    );
  }

  bool _isConditionalTarget(String questionIdToCheck) {
    bool hasExpressionTarget(String target, Expression expression) {
      if (expression is ValueExpression) {
        return expression.target == target;
      } else if (expression is NotExpression) {
        return hasExpressionTarget(target, expression.expression);
      } else {
        // Handle other expression types if necessary
        return false;
      }
    }

    // Get all questions that are following the question that was just answered
    final followUpQuestions = widget.questions.sublist(
      widget.questions.indexOf(
            widget.questions.firstWhere((q) => q.id == questionIdToCheck),
          ) +
          1,
    );
    // Check if any of those questions has a conditional that targets the question that was just answered
    return followUpQuestions.any(
      (q) =>
          q.conditional?.condition.expressions.any((expression) {
            return hasExpressionTarget(questionIdToCheck, expression);
          }) ??
          false,
    );
  }

  Question? _insertQuestion(int index) {
    // Find the next question in the list that should be shown.
    for (int i = index + 1; i < widget.questions.length; i++) {
      if (widget.questions[i].shouldBeShown(qs)) {
        _addQuestionToList(widget.questions[i]);
        _listKey.currentState?.insertItem(shownQuestions.length - 1);

        return widget.questions[i];
      } else {
        // If the next question should not be shown, add default answer or skip it.
        final questionToSkip = widget.questions[i];
        if (questionToSkip.getDefaultAnswer() != null) {
          final defaultAnswer = questionToSkip.getDefaultAnswer()!;
          qs.answers[defaultAnswer.question] = defaultAnswer;
        } else {}
      }
    }
    return null;
  }

  void _resetQuestionnaireTo(String resetToQuestionId) {
    // Remove all answers that were given after the resetToQuestionId
    qs.answers.removeWhere(
      (key, value) =>
          widget.questions.indexOf(
            widget.questions.firstWhere((q) => q.id == key),
          ) >
          widget.questions.indexOf(
            widget.questions.firstWhere((q) => q.id == resetToQuestionId),
          ),
    );

    // Remove all shown questions that were added after the resetToQuestionId
    final resetIndex = shownQuestions.indexWhere(
      (q) => q.question.id == resetToQuestionId,
    );
    if (resetIndex >= 0 && resetIndex < shownQuestions.length - 1) {
      // Remove from the end to the one after resetIndex
      for (int i = shownQuestions.length - 1; i > resetIndex; i--) {
        final removedQuestion = shownQuestions.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) =>
              SizeTransition(sizeFactor: animation, child: removedQuestion),
        );
      }
    }
  }

  void _onQuestionDone(Answer answer, int index) {
    qs.answers[answer.question] = answer;
    final shouldContinue = widget.shouldContinue?.call(qs);
    // Check if the last question was answered or if the questionnaire should not continue.
    if (shouldContinue == false ||
        widget.questions.last.id == answer.question) {
      _finishQuestionnaire(qs);
      return;
    }
    // Check if the question that was answered is the last shown question.
    if (answer.question == shownQuestions.last.question.id) {
      // If the last question displayed was answered, we can try to insert the next question.
      // Index is incorrect if questions are skipped, use last shown question index instead
      _insertQuestion(widget.questions.indexOf(shownQuestions.last.question));
    } else {
      // Check if there are questions whose visibility depend on the question that's answer was just edited.
      if (_isConditionalTarget(answer.question)) {
        _resetQuestionnaireTo(answer.question);
        // Try to insert the next question after the reset.
        final insertedQuestion = _insertQuestion(index);
        if (insertedQuestion != null) {
          // If a question was inserted, the questionnaire is not finished yet.
          _finishQuestionnaire(null);
        }
      }
    }

    // Scroll to the newly added question.
    // Delay scroll until after the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // todo non-optimal solution, but works for now
      Timer(const Duration(milliseconds: 200), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.questions.isNotEmpty) {
      _addQuestionToList(widget.questions.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      controller: _scrollController,
      initialItemCount: shownQuestions.length,
      itemBuilder: (context, index, animation) {
        return Column(
          children: [
            // Header
            if (index == 0 &&
                widget.header != null &&
                widget.header!.isNotEmpty)
              HtmlTextBox(widget.header),
            // Question
            SizeTransition(sizeFactor: animation, child: shownQuestions[index]),
            // Footer
            if (index == shownQuestions.length &&
                widget.footer != null &&
                widget.footer!.isNotEmpty)
              HtmlTextBox(widget.footer),
          ],
        );
      },
    );
  }
}

class HtmlTextBox extends StatelessWidget {
  final String? text;

  const HtmlTextBox(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [HtmlText(text)],
        ),
      ),
    );
  }
}
