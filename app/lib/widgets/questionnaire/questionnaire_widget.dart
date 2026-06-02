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
  late final QuestionnaireController _controller;
  final List<QuestionContainer> shownQuestions = <QuestionContainer>[];
  final List<GlobalKey> questionKeys = <GlobalKey>[];
  final _scrollController = ScrollController();
  bool _isProgrammaticScroll = false;

  // Stable keys reused across rebuilds to preserve widget state.
  final Map<String, GlobalKey> _containerKeys = {};
  final Map<String, GlobalKey<FreeTextQuestionWidgetState>> _freeTextKeys = {};

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

    return _controller.buildVisiblePayload();
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

  void _finishQuestionnaire(QuestionnaireState? result) =>
      widget.onComplete?.call(result);

  void _handleGlobalCtaPressed() {
    final payload = validateSyncAndBuildPayload();
    if (payload == null) return;

    setState(() => _rebuildShownQuestionsFromController());

    if (_controller.allVisibleQuestionsAnswered) {
      _finishQuestionnaire(payload);
    } else {
      _finishQuestionnaire(null);
      _scrollToNewQuestion();
    }
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
      _finishQuestionnaire(_controller.buildVisiblePayload());
      return;
    }

    setState(() => _rebuildShownQuestionsFromController());

    if (_controller.allVisibleQuestionsAnswered) {
      _finishQuestionnaire(_controller.buildVisiblePayload());
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
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: shownQuestions.length,
            itemBuilder: (context, index) {
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
                    child: KeyedSubtree(
                      key: ValueKey(question.question.id),
                      child: question,
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
        _buildCtaBar(),
      ],
    );
  }

  Widget _buildCtaBar() {
    final mode = _controller.ctaModeFor(shownQuestions.map((c) => c.question));
    if (mode == QuestionnaireCtaMode.hidden) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final label = mode == QuestionnaireCtaMode.continue_
        ? l10n.continue_label
        : l10n.complete;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _handleGlobalCtaPressed,
        child: Text(label),
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
