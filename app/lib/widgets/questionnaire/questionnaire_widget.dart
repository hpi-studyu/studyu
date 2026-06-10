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
  State<StatefulWidget> createState() => QuestionnaireWidgetState();
}

class QuestionnaireWidgetState extends State<QuestionnaireWidget> {
  final List<QuestionContainer> shownQuestions = <QuestionContainer>[];
  final List<GlobalKey> questionKeys = <GlobalKey>[];
  final List<GlobalKey<QuestionContainerState>> questionStateKeys =
      <GlobalKey<QuestionContainerState>>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();
  bool _isProgrammaticScroll = false;

  final QuestionnaireState qs = QuestionnaireState();
  final Map<String, Answer> _hiddenAnswersByQuestionId = <String, Answer>{};
  final Set<String> _hiddenDefaultAnswerIds = <String>{};

  Set<String> get _visibleQuestionIds =>
      shownQuestions.map((shownQuestion) => shownQuestion.question.id).toSet();

  QuestionnaireState _buildVisibleQuestionnaireState() {
    return _buildQuestionnaireStateFor(_visibleQuestionIds);
  }

  QuestionnaireState _buildQuestionnaireStateFor(Set<String> questionIds) {
    final result = QuestionnaireState();
    for (final entry in qs.answers.entries) {
      if (questionIds.contains(entry.key)) {
        result.answers[entry.key] = entry.value;
      }
    }
    return result;
  }

  QuestionnaireState? validateSyncAndBuildPayload() {
    final visibleQuestionIdsAtClick = _visibleQuestionIds;
    final containersAtClick = List<QuestionContainer>.of(shownQuestions);
    final stateKeysAtClick = List<GlobalKey<QuestionContainerState>>.of(
      questionStateKeys,
    );
    final renderKeysAtClick = List<GlobalKey>.of(questionKeys);

    int? firstInvalidIndex;
    BuildContext? firstInvalidContext;

    for (int i = 0; i < containersAtClick.length; i++) {
      final result =
          stateKeysAtClick[i].currentState?.validateForComplete() ??
          const QuestionValidationResult.valid();
      final questionId = containersAtClick[i].question.id;
      if (!result.isValid || !qs.answers.containsKey(questionId)) {
        firstInvalidIndex ??= i;
        firstInvalidContext ??= result.invalidContext;
      }
    }

    if (firstInvalidIndex != null) {
      final renderKey = renderKeysAtClick[firstInvalidIndex];
      _scrollToQuestion(renderKey, firstInvalidContext);
      return null;
    }

    for (int i = 0; i < containersAtClick.length; i++) {
      final answer = stateKeysAtClick[i].currentState?.syncForComplete();
      if (answer != null) {
        qs.answers[answer.question] = answer;
      }
    }

    return _buildQuestionnaireStateFor(visibleQuestionIdsAtClick);
  }

  void _cacheAnswerFor(String questionId) {
    final answer = qs.answers.remove(questionId);
    if (answer != null) {
      if (_hiddenDefaultAnswerIds.remove(questionId)) {
        return;
      }
      _hiddenAnswersByQuestionId[questionId] = answer;
    }
  }

  bool _supportsInitialAnswerRestore(Question question) {
    // Only question widgets that can render an initial answer may restore
    // cached hidden answers into UI and questionnaire state.
    return question is BooleanQuestion ||
        question is ChoiceQuestion ||
        question is ScaleQuestion ||
        question is FreeTextQuestion ||
        question is AnnotatedScaleQuestion ||
        // todo remove this when older studies are finished
        // ignore: deprecated_member_use_from_same_package
        question is VisualAnalogueQuestion;
  }

  Answer? _restoreCachedAnswerFor(Question question) {
    // Supported restore: Boolean, Choice, Scale, FreeText, AnnotatedScale,
    // VisualAnalogue. Unsupported restore: Image, Audio, Pain, Fitbit.
    // Unsupported answers stay cached while hidden, but are not restored into
    // qs.answers when shown again because those widgets cannot show restored
    // captured/uploaded/pain/fitbit values yet. This avoids marking a visible
    // question complete when UI does not reflect the restored value.
    if (!_supportsInitialAnswerRestore(question)) return null;

    final answer = _hiddenAnswersByQuestionId.remove(question.id);
    if (answer != null) {
      qs.answers[question.id] = answer;
    }
    _hiddenDefaultAnswerIds.remove(question.id);
    return answer;
  }

  void _applyDefaultAnswerForHiddenQuestion(Question question) {
    final defaultAnswer = question.getDefaultAnswer();
    if (defaultAnswer == null) return;

    qs.answers[question.id] = defaultAnswer;
    _hiddenDefaultAnswerIds.add(question.id);
  }

  void _finishQuestionnaire(QuestionnaireState? result) =>
      widget.onComplete?.call(result);

  void _onQuestionCleared(String questionId) {
    qs.answers.remove(questionId);
    _finishQuestionnaire(null);
  }

  QuestionContainer _buildQuestionContainer({
    required Question question,
    required int index,
    required GlobalKey containerKey,
    required GlobalKey<QuestionContainerState> stateKey,
    required bool isLastQuestion,
    Answer? initialAnswer,
  }) {
    return QuestionContainer(
      key: stateKey,
      containerKey: containerKey,
      question: question,
      onDone: _onQuestionDone,
      onCleared: () => _onQuestionCleared(question.id),
      onInvalid: _onQuestionInvalid,
      index: index,
      taskId: widget.taskId,
      isLastQuestion: isLastQuestion,
      hasConditionalDependents: _isConditionalTarget(question.id),
      initialAnswer: initialAnswer,
    );
  }

  void _refreshLastQuestionFlags() {
    for (int i = 0; i < shownQuestions.length; i++) {
      final current = shownQuestions[i];
      shownQuestions[i] = _buildQuestionContainer(
        containerKey: current.containerKey!,
        stateKey: questionStateKeys[i],
        question: current.question,
        index: current.index,
        isLastQuestion: i == shownQuestions.length - 1,
        initialAnswer: current.initialAnswer,
      );
    }
  }

  void _addQuestionToList(Question question) {
    final containerKey = GlobalKey();
    final stateKey = GlobalKey<QuestionContainerState>();
    final initialAnswer = _supportsInitialAnswerRestore(question)
        ? _restoreCachedAnswerFor(question) ?? qs.answers[question.id]
        : null;
    questionKeys.add(containerKey);
    questionStateKeys.add(stateKey);
    shownQuestions.add(
      _buildQuestionContainer(
        containerKey: containerKey,
        stateKey: stateKey,
        question: question,
        index: shownQuestions.length,
        isLastQuestion: true,
        initialAnswer: initialAnswer,
      ),
    );
    _refreshLastQuestionFlags();
  }

  bool _isConditionalTarget(String questionIdToCheck) {
    bool hasExpressionTarget(String target, Expression expression) {
      if (expression is ValueExpression) {
        return expression.target == target;
      } else if (expression is NotExpression) {
        return hasExpressionTarget(target, expression.expression);
      } else if (expression is CompositeExpression) {
        return expression.expressions.any(
          (expression) => hasExpressionTarget(target, expression),
        );
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
    Question? firstInsertedQuestion;

    // Find the next question in the list that should be shown.
    for (int i = index + 1; i < widget.questions.length; i++) {
      if (widget.questions[i].shouldBeShown(qs)) {
        _addQuestionToList(widget.questions[i]);
        _listKey.currentState?.insertItem(shownQuestions.length - 1);
        setState(_refreshLastQuestionFlags);

        firstInsertedQuestion ??= widget.questions[i];

        if (!qs.answers.containsKey(widget.questions[i].id)) {
          return firstInsertedQuestion;
        }
      } else {
        // If the next question should not be shown, skip it.
        _applyDefaultAnswerForHiddenQuestion(widget.questions[i]);
      }
    }
    return firstInsertedQuestion;
  }

  void _resetQuestionnaireTo(String resetToQuestionId) {
    final resetQuestionIndex = widget.questions.indexOf(
      widget.questions.firstWhere((q) => q.id == resetToQuestionId),
    );

    // Cache all answers that were given after the resetToQuestionId.
    final answerIdsToCache = qs.answers.keys.where((questionId) {
      final questionIndex = widget.questions.indexOf(
        widget.questions.firstWhere((q) => q.id == questionId),
      );
      return questionIndex > resetQuestionIndex;
    }).toList();
    for (final questionId in answerIdsToCache) {
      _cacheAnswerFor(questionId);
    }

    // Remove all shown questions that were added after the resetToQuestionId
    final resetIndex = shownQuestions.indexWhere(
      (q) => q.question.id == resetToQuestionId,
    );
    if (resetIndex >= 0 && resetIndex < shownQuestions.length - 1) {
      // Remove from the end to the one after resetIndex
      for (int i = shownQuestions.length - 1; i > resetIndex; i--) {
        final removedQuestion = shownQuestions.removeAt(i);
        questionKeys.removeAt(i);
        questionStateKeys.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) =>
              SizeTransition(sizeFactor: animation, child: removedQuestion),
        );
      }
      setState(_refreshLastQuestionFlags);
    }
  }

  void _onQuestionInvalid(int index) {
    final questionId = shownQuestions[index].question.id;
    qs.answers.remove(questionId);
    // Only remove later visible questions when the invalidated question has
    // conditional dependents that may hide/change downstream questions.
    if (_isConditionalTarget(questionId)) {
      _resetQuestionnaireTo(questionId);
    }
    _finishQuestionnaire(null);
  }

  bool _allShownQuestionsAnswered() {
    return shownQuestions.every(
      (shownQuestion) => qs.answers.containsKey(shownQuestion.question.id),
    );
  }

  void _onQuestionDone(Answer answer, int _) {
    if (kDebugMode) {
      debugPrint(
        "QuestionnaireWidget: Answer received for question ${answer.question} - $answer",
      );
    }
    qs.answers[answer.question] = answer;

    // Check if there are questions whose visibility depend on this question.
    // Remove no-longer-visible questions before continuation predicates run, but
    // do not add newly visible questions until the predicate allows progression.
    final hasConditionalDependencies = _isConditionalTarget(answer.question);
    if (hasConditionalDependencies) {
      _resetQuestionnaireTo(answer.question);
    }

    final shouldContinue = widget.shouldContinue?.call(
      _buildVisibleQuestionnaireState(),
    );

    // Check if the questionnaire should not continue
    if (shouldContinue == false) {
      _finishQuestionnaire(_buildVisibleQuestionnaireState());
      return;
    }

    if (hasConditionalDependencies) {
      final insertedQuestion = _insertAfterQuestion(answer.question);
      _finishAfterConditionalQuestionChange(insertedQuestion);
      return;
    }

    final currentQuestionIndex = widget.questions.indexWhere(
      (q) => q.id == answer.question,
    );

    // Try to insert the next question for normal progression. Hidden questions
    // may contribute default answers that make later questions visible, so this
    // must happen before deciding that the questionnaire is complete.
    if (answer.question == shownQuestions.last.question.id) {
      final insertedQuestion = _insertQuestion(currentQuestionIndex);
      if (insertedQuestion != null) {
        if (_allShownQuestionsAnswered()) {
          _finishQuestionnaire(_buildVisibleQuestionnaireState());
        } else {
          _scrollToNewQuestion();
        }
      } else {
        _finishQuestionnaire(_buildVisibleQuestionnaireState());
      }
      return;
    }

    // A previously shown question was answered again. If every currently
    // visible question already has a valid answer, restore the completed state.
    if (_allShownQuestionsAnswered()) {
      _finishQuestionnaire(_buildVisibleQuestionnaireState());
    }
  }

  Question? _insertAfterQuestion(String questionId) {
    final currentQuestionIndex = widget.questions.indexWhere(
      (q) => q.id == questionId,
    );

    // Try to insert the next question that should be shown. Hidden questions
    // may contribute default answers that make later questions visible.
    return _insertQuestion(currentQuestionIndex);
  }

  void _finishAfterConditionalQuestionChange(Question? insertedQuestion) {
    if (insertedQuestion != null) {
      // A new question was inserted; restore completion only if it already
      // has cached answers for all visible questions.
      if (_allShownQuestionsAnswered()) {
        _finishQuestionnaire(_buildVisibleQuestionnaireState());
      } else {
        _finishQuestionnaire(null);
        _scrollToNewQuestion();
      }
    } else {
      // No more questions to show - finish questionnaire
      _finishQuestionnaire(_buildVisibleQuestionnaireState());
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

  void _scrollToQuestion(GlobalKey targetKey, BuildContext? targetContext) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contextToShow = targetContext ?? targetKey.currentContext;
      if (contextToShow != null && context.mounted) {
        Scrollable.ensureVisible(
          contextToShow,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
      }
    });
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
