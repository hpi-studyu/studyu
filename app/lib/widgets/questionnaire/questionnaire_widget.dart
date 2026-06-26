import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/questionnaire/question_container.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_controller.dart';
import 'package:studyu_app/widgets/questionnaire/questions/free_text_question_widget.dart';
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

  /// When true, the global CTA shows a loading spinner and is disabled.
  /// The parent sets this while it processes a completed submission.
  final bool isSubmitting;

  const QuestionnaireWidget(
    this.questions, {
    this.taskId,
    this.title,
    this.header,
    this.footer,
    this.onComplete,
    this.shouldContinue,
    this.isSubmitting = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => QuestionnaireWidgetState();
}

class QuestionnaireWidgetState extends State<QuestionnaireWidget> {
  late final QuestionnaireController _controller;
  final List<QuestionContainer> shownQuestions = <QuestionContainer>[];
  final List<GlobalKey> questionKeys = <GlobalKey>[];
  final _scrollController = ScrollController();
  bool _isProgrammaticScroll = false;

  // Stable keys reused across rebuilds to preserve widget state.
  final Map<String, GlobalKey> _containerKeys = {};
  final Map<String, GlobalKey<FreeTextQuestionWidgetState>> _freeTextKeys = {};
  final Set<String> _shownReviewErrors = {};

  QuestionnaireState? validateSyncAndBuildPayload() {
    final containersAtClick = List<QuestionContainer>.of(shownQuestions);
    final renderKeysAtClick = List<GlobalKey>.of(questionKeys);

    // Commit all visible free-text drafts. The controller validates drafts
    // and returns the first validation error, or null if all are valid.
    final freeTextToSync = <FreeTextQuestion>[];
    for (int i = 0; i < containersAtClick.length; i++) {
      final container = containersAtClick[i];
      if (container.question is! FreeTextQuestion) continue;
      freeTextToSync.add(container.question as FreeTextQuestion);
    }

    if (freeTextToSync.isNotEmpty) {
      final error = _controller.commitFreeTextDraftsFor(freeTextToSync);
      if (error != null) {
        // Scroll to first actually invalid free-text question.
        for (int i = 0; i < containersAtClick.length; i++) {
          final container = containersAtClick[i];
          if (container.question is! FreeTextQuestion) continue;
          final ftQuestion = container.question as FreeTextQuestion;
          final draft = _controller.draftFor(ftQuestion.id);
          if (ftQuestion.validateResponse(draft) != null) {
            _scrollToQuestion(renderKeysAtClick[i]);
            return null;
          }
        }
        return null;
      }
    }

    // Check non-free-text questions have answers.
    int? firstInvalidIndex;
    for (int i = 0; i < containersAtClick.length; i++) {
      final questionId = containersAtClick[i].question.id;
      final isFreeText = containersAtClick[i].question is FreeTextQuestion;
      if (!isFreeText && _controller.answerFor(questionId) == null) {
        firstInvalidIndex = i;
        break;
      }
    }

    if (firstInvalidIndex != null) {
      _scrollToQuestion(renderKeysAtClick[firstInvalidIndex]);
      return null;
    }

    if (_blockCompletionForReview(
      containers: containersAtClick,
      renderKeys: renderKeysAtClick,
    )) {
      return null;
    }

    return _controller.buildVisiblePayload();
  }

  bool _supportsInitialAnswerRestore(Question question) {
    // Only question widgets that can render an initial answer may restore
    // cached hidden answers into UI and questionnaire state.
    return question is BooleanQuestion ||
        question is ChoiceQuestion ||
        question is ScaleQuestion ||
        question is FreeTextQuestion ||
        question is DateQuestion ||
        question is AnnotatedScaleQuestion ||
        // todo remove this when older studies are finished
        // ignore: deprecated_member_use_from_same_package
        question is VisualAnalogueQuestion;
  }

  Answer? _initialAnswerForQuestion(Question question) {
    if (!_supportsInitialAnswerRestore(question)) return null;

    if (question is FreeTextQuestion) {
      if (_controller.hasDraft(question.id)) {
        final draft = _controller.draftFor(question.id);
        return question.constructAnswer(draft);
      }
    }

    return _controller.answerFor(question.id);
  }

  bool _blockCompletionForReview({
    List<QuestionContainer>? containers,
    List<GlobalKey>? renderKeys,
  }) {
    final reviewQuestionId = _controller.firstVisibleAnswerNeedingReview();
    if (reviewQuestionId == null) return false;

    setState(() => _shownReviewErrors.add(reviewQuestionId));
    final reviewIndex = containers?.indexWhere(
      (container) => container.question.id == reviewQuestionId,
    );
    if (reviewIndex != null &&
        reviewIndex >= 0 &&
        renderKeys != null &&
        reviewIndex < renderKeys.length) {
      _scrollToQuestion(renderKeys[reviewIndex]);
    }
    return true;
  }

  void _finishQuestionnaireIfReviewed(QuestionnaireState payload) {
    if (_blockCompletionForReview()) {
      return;
    }
    _finishQuestionnaire(payload);
  }

  void _finishQuestionnaire(QuestionnaireState? result) {
    widget.onComplete?.call(result);
  }

  void _handleGlobalCtaPressed() {
    // Capture CTA mode before committing — a "Continue" press must never
    // submit; it only advances and reveals the next step.
    final modeBefore = _controller.ctaModeFor(
      shownQuestions.map((c) => c.question),
    );

    final payload = validateSyncAndBuildPayload();
    if (payload == null) return;

    final visibleBeforeRebuild = _controller.visibleQuestions
        .map((question) => question.id)
        .toSet();
    setState(() => _rebuildShownQuestionsFromController());
    _controller.markRestoredVisibleAnswersNeedingReview(visibleBeforeRebuild);

    if (modeBefore == QuestionnaireCtaMode.complete) {
      _finishQuestionnaireIfReviewed(_controller.buildVisiblePayload());
    } else {
      _finishQuestionnaire(null);
      _scrollToNewQuestion();
    }
  }

  void _onQuestionCleared(String questionId) {
    _controller.removeAnswer(questionId);
    setState(() => _rebuildShownQuestionsFromController(revealNext: false));
    _finishQuestionnaire(null);
  }

  QuestionContainer _buildQuestionContainer({
    required Question question,
    required int index,
    required GlobalKey containerKey,
    GlobalKey<FreeTextQuestionWidgetState>? freeTextKey,
    Answer? initialAnswer,
    void Function(String questionId, String value)? onFreeTextDraftChanged,
  }) {
    return QuestionContainer(
      containerKey: containerKey,
      question: question,
      onDone: _onQuestionDone,
      onCleared: () => _onQuestionCleared(question.id),
      index: index,
      taskId: widget.taskId,
      initialAnswer: initialAnswer,
      onFreeTextDraftChanged: onFreeTextDraftChanged,
      freeTextKey: freeTextKey,
    );
  }

  /// Rebuilds [shownQuestions] and [questionKeys] from the controller's
  /// [progressiveVisibleQuestions]. Also cleans up answers for hidden questions
  /// whose type does not support initial answer restore.
  ///
  /// When [revealNext] is true (default), also includes the first
  /// visible unanswered question after the last progressive question,
  /// enabling normal progressive reveal.
  void _rebuildShownQuestionsFromController({bool revealNext = true}) {
    // Clean up answers for hidden unsupported question types so that
    // re-showing them does not auto-restore stale answers.
    final allVisible = _controller.visibleQuestions;
    for (final question in widget.questions) {
      if (!allVisible.any((q) => q.id == question.id)) {
        if (_controller.answerFor(question.id) != null &&
            !_supportsInitialAnswerRestore(question)) {
          _controller.removeAnswer(question.id);
        }
      }
    }

    shownQuestions.clear();
    questionKeys.clear();

    final progressive = _controller.progressiveVisibleQuestions;
    final questionsToShow = List<Question>.from(progressive);

    // If enabled, reveal the first visible unanswered question after
    // the last progressive question.
    if (revealNext) {
      final visible = _controller.visibleQuestions;
      final progressiveIds = progressive.map((q) => q.id).toSet();
      for (final q in visible) {
        if (!progressiveIds.contains(q.id)) {
          questionsToShow.add(q);
          break;
        }
      }
    }

    for (int i = 0; i < questionsToShow.length; i++) {
      final question = questionsToShow[i];
      final containerKey = _containerKeys.putIfAbsent(
        question.id,
        () => GlobalKey(debugLabel: 'container_${question.id}'),
      );
      final freeTextKey = question is FreeTextQuestion
          ? _freeTextKeys.putIfAbsent(
              question.id,
              () => GlobalKey<FreeTextQuestionWidgetState>(
                debugLabel: 'free_text_state_${question.id}',
              ),
            )
          : null;
      final initialAnswer = _initialAnswerForQuestion(question);
      questionKeys.add(containerKey);
      shownQuestions.add(
        _buildQuestionContainer(
          containerKey: containerKey,
          question: question,
          index: i,
          initialAnswer: initialAnswer,
          onFreeTextDraftChanged: _controller.updateFreeTextDraft,
          freeTextKey: freeTextKey,
        ),
      );
    }
  }

  void _onQuestionDone(Answer answer, int _) {
    if (kDebugMode) {
      debugPrint(
        "QuestionnaireWidget: Answer received for question ${answer.question} - $answer",
      );
    }
    _controller.submitAnswer(answer);

    // Check shouldContinue before revealing new questions in the UI.
    // This prevents prematurely revealing questions that the continuation
    // predicate would stop.
    final shouldContinue = widget.shouldContinue?.call(
      _controller.buildVisiblePayload(),
    );

    if (shouldContinue == false) {
      setState(() => _rebuildShownQuestionsFromController(revealNext: false));
      _finishQuestionnaire(null);
      return;
    }

    final visibleBeforeRebuild = _controller.visibleQuestions
        .map((question) => question.id)
        .toSet();
    setState(() => _rebuildShownQuestionsFromController());
    _controller.markRestoredVisibleAnswersNeedingReview(visibleBeforeRebuild);

    if (_controller.allVisibleQuestionsAnswered) {
      _scrollToNewQuestion();
    } else {
      if (_controller.hasConditionalDependents(answer.question)) {
        _finishQuestionnaire(null);
      }
      _scrollToNewQuestion();
    }
  }

  void _scrollToNewQuestion() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetIndex = _findNextInteractiveQuestionIndex();
      if (targetIndex < 0 || targetIndex >= questionKeys.length) return;
      final targetContext = questionKeys[targetIndex].currentContext;
      if (targetContext == null || !context.mounted) return;
      _isProgrammaticScroll = true;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: 0.2,
      ).whenComplete(() => _isProgrammaticScroll = false);
    });
  }

  int _findNextInteractiveQuestionIndex() {
    for (int i = 0; i < shownQuestions.length; i++) {
      final questionId = shownQuestions[i].question.id;
      if (_controller.answerFor(questionId) == null) {
        return i;
      }
    }
    return shownQuestions.length - 1;
  }

  void _scrollToQuestion(GlobalKey targetKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = targetKey.currentContext;
      if (targetContext != null && context.mounted) {
        Scrollable.ensureVisible(
          targetContext,
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

    _controller = QuestionnaireController(widget.questions);
    _controller.addListener(_onControllerChanged);

    if (widget.questions.isNotEmpty) {
      _rebuildShownQuestionsFromController(revealNext: false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    // Defer to post-frame to avoid setState during the build phase
    // (e.g. when FreeTextQuestionWidget.initState restores an initial
    // answer and immediately calls onDraftChanged).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
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
    final ctaMode = _controller.ctaModeFor(
      shownQuestions.map((c) => c.question),
    );
    final showCta = ctaMode != QuestionnaireCtaMode.hidden;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: shownQuestions.length + (showCta ? 1 : 0),
            itemBuilder: (context, index) {
              if (showCta && index == shownQuestions.length) {
                return _buildCtaBar(ctaMode);
              }
              final question = shownQuestions[index];
              return Column(
                children: [
                  if (index == 0 &&
                      widget.header != null &&
                      widget.header!.isNotEmpty)
                    HtmlTextBox(widget.header),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        question,
                        if (_controller.needsReview(question.question.id))
                          _buildReviewRequiredBanner(question.question.id),
                      ],
                    ),
                  ),
                  if (index == shownQuestions.length - 1 &&
                      widget.footer != null &&
                      widget.footer!.isNotEmpty)
                    HtmlTextBox(widget.footer),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRequiredBanner(String questionId) {
    final l10n = AppLocalizations.of(context)!;
    final showError = _shownReviewErrors.contains(questionId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        color: showError ? Colors.red.shade50 : Colors.amber.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    showError ? Icons.error_outline : Icons.info_outline,
                    color: showError
                        ? Colors.red.shade700
                        : const Color(0xFF92400E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.restored_answer_needs_review,
                      style: TextStyle(
                        color: showError
                            ? Colors.red.shade900
                            : const Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _shownReviewErrors.remove(questionId));
                    _controller.markReviewed(questionId);
                  },
                  icon: const Icon(Icons.check),
                  label: Text(l10n.mark_answer_reviewed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCtaBar(QuestionnaireCtaMode mode) {
    final l10n = AppLocalizations.of(context)!;
    final isContinue = mode == QuestionnaireCtaMode.continue_;
    final label = isContinue ? l10n.continue_label : l10n.complete;
    final backgroundColor = isContinue ? Colors.orange.shade700 : Colors.green;
    final isSubmitting = widget.isSubmitting;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton.icon(
          icon: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(isContinue ? Icons.arrow_forward : Icons.check),
          label: Text(label),
          onPressed: isSubmitting ? null : _handleGlobalCtaPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: backgroundColor.withValues(alpha: 0.7),
            disabledForegroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
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
