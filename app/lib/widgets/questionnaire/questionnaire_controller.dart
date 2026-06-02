import 'package:flutter/foundation.dart';
import 'package:studyu_core/core.dart';

enum QuestionnaireCtaMode { hidden, continue_, complete }

class QuestionnaireController extends ChangeNotifier {
  QuestionnaireController(this.questions);

  final List<Question> questions;
  final QuestionnaireState _answers = QuestionnaireState();
  final Map<String, String> _drafts = {};

  /// Returns a defensive snapshot of the internal cached answers.
  ///
  /// May include answers to hidden questions and default answers applied
  /// internally. For persistence or submission, use [buildVisiblePayload]
  /// instead.
  QuestionnaireState get answers {
    final copy = QuestionnaireState();
    copy.answers.addAll(_answers.answers);
    return copy;
  }

  List<Question> get visibleQuestions {
    return _deriveVisibleQuestions();
  }

  /// Returns visible questions in order, up to (but not including) the first
  /// unanswered visible question after the first. The first visible question
  /// is always included even if unanswered.
  /// This captures the "answered" portion of progressive reveal; the next
  /// visible unanswered question is added separately by the widget.
  List<Question> get progressiveVisibleQuestions {
    final result = <Question>[];
    for (final question in visibleQuestions) {
      if (!_answers.answers.containsKey(question.id)) {
        if (result.isEmpty) {
          result.add(question);
        }
        break;
      }
      result.add(question);
    }
    return result;
  }

  bool get allVisibleQuestionsAnswered {
    return visibleQuestions.every(
      (question) => _answers.answers.containsKey(question.id),
    );
  }

  /// Returns true if any later question's conditional targets [questionId].
  /// Mirrors the logic formerly in QuestionnaireWidgetState._isConditionalTarget.
  bool hasConditionalDependents(String questionId) {
    final questionIndex = questions.indexWhere((q) => q.id == questionId);
    if (questionIndex == -1) return false;

    final followUpQuestions = questions.sublist(questionIndex + 1);

    return followUpQuestions.any((q) {
      return q.conditional?.condition.expressions.any((expression) {
            return _hasExpressionTarget(questionId, expression);
          }) ??
          false;
    });
  }

  bool _hasExpressionTarget(String target, Expression expression) {
    if (expression is ValueExpression) {
      return expression.target == target;
    } else if (expression is NotExpression) {
      return _hasExpressionTarget(target, expression.expression);
    } else if (expression is CompositeExpression) {
      return expression.expressions.any((e) => _hasExpressionTarget(target, e));
    }
    return false;
  }

  QuestionnaireState _evaluationStateWith(Map<String, Answer> answers) {
    final state = QuestionnaireState();
    state.answers.addAll(answers);
    return state;
  }

  bool _isQuestionVisibleInState(
    Question question,
    QuestionnaireState evaluationState,
  ) {
    final conditional = question.conditional;
    if (conditional == null) return true;
    return conditional.condition.evaluate(evaluationState) == true;
  }

  Answer? _defaultAnswerForHiddenQuestion(Question question) {
    return question.getDefaultAnswer();
  }

  List<Question> _deriveVisibleQuestions({bool applyHiddenDefaults = false}) {
    final visible = <Question>[];
    final evaluationAnswers = <String, Answer>{};

    for (final question in questions) {
      final evaluationState = _evaluationStateWith(evaluationAnswers);
      final isVisible = _isQuestionVisibleInState(question, evaluationState);

      if (isVisible) {
        visible.add(question);
        final answer = _answers.answers[question.id];
        if (answer != null) evaluationAnswers[question.id] = answer;
      } else {
        final defaultAnswer = _defaultAnswerForHiddenQuestion(question);
        if (defaultAnswer != null) {
          if (applyHiddenDefaults) {
            _answers.answers.putIfAbsent(question.id, () => defaultAnswer);
          }
          if (applyHiddenDefaults ||
              _answers.answers.containsKey(question.id)) {
            evaluationAnswers[question.id] = defaultAnswer;
          }
        }
      }
    }

    return visible;
  }

  /// Applies default answers to hidden questions that have defaults,
  /// so downstream visibility computation can reference them.
  void _applyHiddenDefaults() {
    _deriveVisibleQuestions(applyHiddenDefaults: true);
  }

  Answer? answerFor(String questionId) {
    return _answers.answers[questionId];
  }

  /// Removes a cached answer for [questionId] from the internal state.
  ///
  /// Keeps any existing draft for the same id so that the user may continue
  /// editing after invalidation. Notifies listeners only when an answer was
  /// actually removed.
  void removeAnswer(String questionId) {
    if (_answers.answers.remove(questionId) != null) {
      notifyListeners();
    }
  }

  String draftFor(String questionId) {
    return _drafts[questionId] ?? '';
  }

  bool hasDraft(String questionId) {
    return _drafts.containsKey(questionId);
  }

  void submitAnswer(Answer answer) {
    _answers.answers[answer.question] = answer;
    _applyHiddenDefaults();
    notifyListeners();
  }

  void updateFreeTextDraft(String questionId, String value) {
    if (_drafts[questionId] == value) return;
    _drafts[questionId] = value;
    notifyListeners();
  }

  void commitFreeTextDraft(FreeTextQuestion question) {
    final draft = _drafts[question.id];
    if (draft == null) return;
    _drafts.remove(question.id);
    submitAnswer(question.constructAnswer(draft));
  }

  /// Commits free-text drafts for the given questions into [answers].
  ///
  /// Returns the first [FreeTextValidationError] encountered, or `null` if all
  /// drafts are valid and committed. Avoids notifying listeners when no
  /// answer changed.
  FreeTextValidationError? commitFreeTextDraftsFor(
    Iterable<FreeTextQuestion> questions,
  ) {
    var changed = false;
    for (final question in questions) {
      final draft = _drafts[question.id];
      if (draft == null) continue;
      final error = question.validateResponse(draft);
      if (error != null) return error;
      final existingAnswer = _answers.answers[question.id];
      if (existingAnswer == null || existingAnswer.response != draft) {
        _answers.answers[question.id] = question.constructAnswer(draft);
        _drafts.remove(question.id);
        changed = true;
      }
    }
    if (changed) {
      _applyHiddenDefaults();
      notifyListeners();
    }
    return null;
  }

  /// Returns `true` when any [FreeTextQuestion] in [questions] carries a
  /// non-empty draft that fails validation. Used to suppress the global CTA
  /// while a visible free-text field has an error.
  bool hasInvalidDraftAmong(Iterable<Question> questions) {
    for (final question in questions.whereType<FreeTextQuestion>()) {
      final draft = _drafts[question.id];
      if (draft == null || draft.isEmpty) continue;
      if (question.validateResponse(draft) != null) return true;
    }
    return false;
  }

  /// Commits free-text drafts for all currently visible free-text questions.
  ///
  /// Prefer [commitFreeTextDraftsFor] in progressive UI contexts where the
  /// visible set may differ from [visibleQuestions].
  FreeTextValidationError? commitVisibleFreeTextDrafts() {
    final visibleFreeText = visibleQuestions.whereType<FreeTextQuestion>();
    return commitFreeTextDraftsFor(visibleFreeText);
  }

  QuestionnaireState buildVisiblePayload() {
    final visibleIds = visibleQuestions.map((q) => q.id).toSet();
    final result = QuestionnaireState();
    for (final entry in _answers.answers.entries) {
      if (visibleIds.contains(entry.key)) {
        result.answers[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Returns `true` when any visible [FreeTextQuestion] that has conditional
  /// dependents carries a draft whose value differs from the currently
  /// committed answer (or has no committed answer yet).
  ///
  /// This signals that pressing the global CTA will change which follow-up
  /// questions are visible.
  ///
  bool _hasPendingBranchChangeFor(Iterable<Question> questions) {
    for (final q in questions.whereType<FreeTextQuestion>()) {
      if (!hasConditionalDependents(q.id)) continue;
      final draft = _drafts[q.id];
      if (draft == null || draft.isEmpty) continue;
      final answer = _answers.answers[q.id];
      if (answer == null ||
          (answer is Answer<String> && answer.response != draft)) {
        return true;
      }
    }
    return false;
  }

  /// Uses [progressiveVisibleQuestions] to match what the user sees rather
  /// than all technically visible questions.
  bool get hasPendingBranchChange {
    return _hasPendingBranchChangeFor(progressiveVisibleQuestions);
  }

  /// Determines which CTA to show for the given [questions].
  ///
  /// - [QuestionnaireCtaMode.hidden]: no visible question has any input or no
  ///   CTA action can be taken.
  /// - [QuestionnaireCtaMode.continue_]: a visible free-text draft can be
  ///   committed but pressing the CTA should advance rather than complete.
  /// - [QuestionnaireCtaMode.complete]: pressing the CTA can produce a final
  ///   visible-answer payload.
  QuestionnaireCtaMode ctaModeFor(Iterable<Question> questions) {
    final questionList = questions.toList(growable: false);
    if (questionList.isEmpty) return QuestionnaireCtaMode.hidden;

    // Never offer a CTA while a shown free-text field has an invalid draft.
    if (hasInvalidDraftAmong(questionList)) return QuestionnaireCtaMode.hidden;

    final visibleQuestionIds = visibleQuestions
        .map((question) => question.id)
        .toSet();
    final shownQuestionIds = questionList
        .map((question) => question.id)
        .toSet();
    final hasUnshownVisibleQuestion = visibleQuestionIds
        .difference(shownQuestionIds)
        .isNotEmpty;
    var hasVisibleDraft = false;
    var hasAnyInput = false;
    var allShownHaveInput = true;

    for (final question in questionList) {
      final answer = answerFor(question.id);
      final draft = question is FreeTextQuestion ? draftFor(question.id) : null;
      final hasDraftInput = draft != null && draft.isNotEmpty;
      // A draft only counts as "pending" (requiring a Continue commit) when it
      // differs from the committed answer. A restored draft that mirrors the
      // committed answer is not pending and must not force a Continue CTA.
      final hasPendingDraft =
          hasDraftInput &&
          (answer == null ||
              (answer is Answer<String> && answer.response != draft));
      final hasInput = answer != null || hasDraftInput;
      hasVisibleDraft = hasVisibleDraft || hasPendingDraft;
      hasAnyInput = hasAnyInput || hasInput;
      allShownHaveInput = allShownHaveInput && hasInput;
    }

    if (!hasAnyInput) return QuestionnaireCtaMode.hidden;

    if (_hasPendingBranchChangeFor(questionList)) {
      return QuestionnaireCtaMode.continue_;
    }

    if (hasVisibleDraft && (!allShownHaveInput || hasUnshownVisibleQuestion)) {
      return QuestionnaireCtaMode.continue_;
    }

    if (allShownHaveInput) return QuestionnaireCtaMode.complete;
    return QuestionnaireCtaMode.hidden;
  }

  /// Convenience getter that computes [ctaModeFor] for
  /// [progressiveVisibleQuestions].
  QuestionnaireCtaMode get ctaMode => ctaModeFor(progressiveVisibleQuestions);
}
