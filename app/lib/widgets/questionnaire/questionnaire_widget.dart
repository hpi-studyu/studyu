import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final List<GlobalKey> questionKeys = <GlobalKey>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();
  bool _isProgrammaticScroll = false;

  final QuestionnaireState qs = QuestionnaireState();

  void _finishQuestionnaire(QuestionnaireState? result) =>
      widget.onComplete?.call(result);

  void _addQuestionToList(Question question) {
    final containerKey = GlobalKey();
    questionKeys.add(containerKey);
    shownQuestions.add(
      QuestionContainer(
        key: UniqueKey(),
        containerKey: containerKey,
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
        questionKeys.removeAt(i);
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

    // Check if there are any more questions that should be shown
    final currentQuestionIndex = widget.questions.indexWhere(
      (q) => q.id == answer.question,
    );
    bool hasMoreQuestions = false;

    // Look for any remaining questions that should be shown
    for (int i = currentQuestionIndex + 1; i < widget.questions.length; i++) {
      if (widget.questions[i].shouldBeShown(qs)) {
        hasMoreQuestions = true;
        break;
      }
    }

    // Check if the questionnaire should not continue or if there are no more questions to show
    if (shouldContinue == false || !hasMoreQuestions) {
      _finishQuestionnaire(qs);
      return;
    }

    _processQuestionCompletion(answer, index);
  }

  void _processQuestionCompletion(Answer answer, int index) {
    bool questionWasInserted = false;

    // Check if the question that was answered is the last shown question.
    if (answer.question == shownQuestions.last.question.id) {
      // If the last question displayed was answered, we can try to insert the next question.
      // Index is incorrect if questions are skipped, use last shown question index instead
      final insertedQuestion = _insertQuestion(
        widget.questions.indexOf(shownQuestions.last.question),
      );
      questionWasInserted = insertedQuestion != null;
    } else {
      // Check if there are questions whose visibility depend on the question that's answer was just edited.
      if (_isConditionalTarget(answer.question)) {
        _resetQuestionnaireTo(answer.question);
        // Try to insert the next question after the reset.
        final answeredQuestionIndex = widget.questions.indexWhere(
          (q) => q.id == answer.question,
        );
        final insertedQuestion = _insertQuestion(answeredQuestionIndex);
        if (insertedQuestion != null) {
          // If a question was inserted, the questionnaire is not finished yet.
          _finishQuestionnaire(null);
          questionWasInserted = true;
        }
      }
    }

    if (questionWasInserted) {
      _scrollToNewQuestion();
    }
  }

  void _scrollToNewQuestion() {
    // Wait for the AnimatedList insertion animation to complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use a longer delay to ensure the AnimatedList animation is complete
      Timer(const Duration(milliseconds: 400), () {
        _performScrollToNewQuestion();
      });
    });
  }

  int _findNextInteractiveQuestionIndex() {
    for (int i = 0; i < shownQuestions.length; i++) {
      final questionId = shownQuestions[i].question.id;
      if (!qs.answers.containsKey(questionId)) {
        return i;
      }
    }
    return shownQuestions.length - 1;
  }

  void _performScrollToNewQuestion({int retryCount = 0}) {
    if (!_scrollController.hasClients || questionKeys.isEmpty) return;

    final targetQuestionIndex = _findNextInteractiveQuestionIndex();
    final targetQuestionKey = questionKeys[targetQuestionIndex];
    final renderObject = targetQuestionKey.currentContext?.findRenderObject();

    if (renderObject is RenderBox) {
      final scrollViewRenderObject =
          _scrollController.position.context.storageContext.findRenderObject()
              as RenderBox?;

      if (scrollViewRenderObject != null) {
        final questionPosition = renderObject.localToGlobal(
          Offset.zero,
          ancestor: scrollViewRenderObject,
        );

        final currentScrollPosition = _scrollController.position.pixels;
        final targetScrollPosition =
            currentScrollPosition + questionPosition.dy;

        final maxScroll = _scrollController.position.maxScrollExtent;
        final finalScrollPosition = targetScrollPosition.clamp(0.0, maxScroll);

        // Mark as programmatic scroll
        _isProgrammaticScroll = true;

        _scrollController
            .animateTo(
              finalScrollPosition,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
              // Reset flag after scroll completes
              _isProgrammaticScroll = false;

              if (retryCount < 2 && _scrollController.hasClients) {
                Timer(const Duration(milliseconds: 100), () {
                  _performScrollToNewQuestion(retryCount: retryCount + 1);
                });
              }
            });
      }
    } else if (retryCount < 3) {
      Timer(const Duration(milliseconds: 100), () {
        _performScrollToNewQuestion(retryCount: retryCount + 1);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Add scroll listener to dismiss keyboard when scrolling
    _scrollController.addListener(_onScroll);

    if (widget.questions.isNotEmpty) {
      _addQuestionToList(widget.questions.first);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isProgrammaticScroll && _scrollController.hasClients) {
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        FocusScope.of(context).unfocus();
      }
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
