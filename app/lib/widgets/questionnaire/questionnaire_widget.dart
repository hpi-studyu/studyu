import 'dart:async';

import 'package:flutter/foundation.dart';
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
  final StateHandler? onChange;
  final ContinuationPredicate? shouldContinue;
  final QuestionnaireState? initialState;

  const QuestionnaireWidget(
    this.questions, {
    this.taskId,
    this.title,
    this.header,
    this.footer,
    this.onComplete,
    this.onChange,
    this.shouldContinue,
    this.initialState,
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

  late final QuestionnaireState qs;

  @override
  void initState() {
    super.initState();
    qs = widget.initialState ?? QuestionnaireState();

    // Add scroll listener to dismiss keyboard when scrolling
    _scrollController.addListener(_onScroll);

    if (widget.questions.isNotEmpty) {
      if (widget.initialState != null) {
        _restoreState();
      } else {
        _addQuestionToList(widget.questions.first);
      }
    }
  }

  void _restoreState() {
    // Re-play the answers to restore the state
    // We need to determine which questions should be shown based on the answers
    // This is a simplified restoration that assumes linear progression or simple conditionals
    // A more robust approach would be to simulate the flow

    // For now, let's try to simulate the flow by "answering" the questions again
    // But we need to be careful not to trigger callbacks or side effects that shouldn't happen during restoration

    // Better approach: Iterate through questions and check if they have an answer or should be shown

    // 1. Always show the first question
    if (widget.questions.isEmpty) return;

    _addQuestionToList(widget.questions.first);

    // 2. Iterate and add subsequent questions if they are answered or should be shown
    // We need to find the last answered question to know where to stop or if we should continue adding

    // Let's try to reconstruct the shownQuestions list based on qs.answers
    // We start with the first question.
    // If it has an answer, we check what the next question should be.

    Question? currentQuestion = widget.questions.first;
    while (currentQuestion != null) {
      final answer = qs.answers[currentQuestion.id];
      if (answer != null) {
        // Question has an answer, so we should check for the next one

        // Logic similar to _onQuestionDone but without finishing

        // Check for conditional dependencies (simplified for restoration)
        // ...

        // Find next question
        final currentQuestionIndex = widget.questions.indexOf(currentQuestion!);
        Question? nextQuestion;

        for (
          int i = currentQuestionIndex + 1;
          i < widget.questions.length;
          i++
        ) {
          if (widget.questions[i].shouldBeShown(qs)) {
            nextQuestion = widget.questions[i];
            break;
          }
        }

        if (nextQuestion != null) {
          _addQuestionToList(nextQuestion);
          currentQuestion = nextQuestion;
        } else {
          currentQuestion = null; // End of flow
        }
      } else {
        // Current question is not answered, so it's the last one shown
        currentQuestion = null;
      }
    }
  }

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
        initialAnswer: qs.answers[question.id],
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
        final defaultAnswer = questionToSkip.getDefaultAnswer();
        if (defaultAnswer != null) {
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
    if (kDebugMode) {
      debugPrint(
        "QuestionnaireWidget: Answer received for question ${answer.question} - $answer",
      );
    }
    qs.answers[answer.question] = answer;
    widget.onChange?.call(qs);
    final shouldContinue = widget.shouldContinue?.call(qs);

    // Check if the questionnaire should not continue
    if (shouldContinue == false) {
      _finishQuestionnaire(qs);
      return;
    }

    // Check if there are questions whose visibility depend on this question
    final hasConditionalDependencies = _isConditionalTarget(answer.question);

    // If this question has conditional dependencies, always process them first
    if (hasConditionalDependencies) {
      _handleConditionalQuestionChange(answer, index);
      return;
    }

    // Check if there are any more questions that should be shown
    final currentQuestionIndex = widget.questions.indexWhere(
      (q) => q.id == answer.question,
    );

    bool hasMoreQuestions = false;
    for (int i = currentQuestionIndex + 1; i < widget.questions.length; i++) {
      if (widget.questions[i].shouldBeShown(qs)) {
        hasMoreQuestions = true;
        break;
      }
    }

    // If no more questions, finish the questionnaire
    if (!hasMoreQuestions) {
      _finishQuestionnaire(qs);
      return;
    }

    // Try to insert the next question for normal progression
    if (answer.question == shownQuestions.last.question.id) {
      final insertedQuestion = _insertQuestion(
        widget.questions.indexOf(shownQuestions.last.question),
      );
      if (insertedQuestion != null) {
        _scrollToNewQuestion();
      }
    }
  }

  void _handleConditionalQuestionChange(Answer answer, int index) {
    // Reset questionnaire to remove any questions that should no longer be shown
    _resetQuestionnaireTo(answer.question);

    // Check if there are any questions that should now be shown
    final currentQuestionIndex = widget.questions.indexWhere(
      (q) => q.id == answer.question,
    );

    bool hasQuestionsToShow = false;
    for (int i = currentQuestionIndex + 1; i < widget.questions.length; i++) {
      if (widget.questions[i].shouldBeShown(qs)) {
        hasQuestionsToShow = true;
        break;
      }
    }

    if (hasQuestionsToShow) {
      // Try to insert the next question that should be shown
      final insertedQuestion = _insertQuestion(currentQuestionIndex);
      if (insertedQuestion != null) {
        // A new question was inserted, reset completion state
        _finishQuestionnaire(null);
        _scrollToNewQuestion();
      } else {
        // No question was inserted but should have been - finish questionnaire
        _finishQuestionnaire(qs);
      }
    } else {
      // No more questions to show - finish questionnaire
      _finishQuestionnaire(qs);
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
    } else if (retryCount < 5) {
      Timer(const Duration(milliseconds: 100), () {
        _scrollToMakeTargetVisible(targetQuestionKey).then((_) {
          _isProgrammaticScroll = false;
          Timer(const Duration(milliseconds: 100), () {
            _performScrollToNewQuestion(retryCount: retryCount + 1);
          });
        });
      });
    } else {
      // Could not find render object after retries
      if (kDebugMode) {
        debugPrint(
          "QuestionnaireWidget: Unable to find render object for question at index $targetQuestionIndex",
        );
      }
    }
  }

  Future<void> _scrollToMakeTargetVisible(GlobalKey targetKey) {
    // Fallback: scroll incrementally until the target question becomes visible
    final viewportHeight = _scrollController.position.viewportDimension;
    final scrollIncrement = viewportHeight * 0.5;
    final currentPosition = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    // Return if already at max scroll
    if (currentPosition >= maxScroll) return Future.value();
    final newPosition = (currentPosition + scrollIncrement).clamp(
      0.0,
      maxScroll,
    );
    _isProgrammaticScroll = true;
    return _scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
