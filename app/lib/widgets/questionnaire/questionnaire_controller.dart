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
    return questions.where(_isQuestionVisible).toList();
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

  /// Returns true if the question should be shown based on current answers.
  /// Questions without conditional are always visible.
  /// Questions with conditional are visible only when condition
  /// evaluates to true (null = hidden).
  bool _isQuestionVisible(Question question) {
    final conditional = question.conditional;
    if (conditional == null) return true;
    return conditional.condition.evaluate(_answers) == true;
  }

  /// Applies default answers to hidden questions that have defaults,
  /// so downstream visibility computation can reference them.
  void _applyHiddenDefaults() {
    for (final question in questions) {
      if (!_isQuestionVisible(question)) {
        if (!_answers.answers.containsKey(question.id)) {
          final defaultAnswer = question.getDefaultAnswer();
          if (defaultAnswer != null) {
            _answers.answers[question.id] = defaultAnswer;
          }
        }
      }
    }
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
  /// Uses [progressiveVisibleQuestions] to match what the user sees rather
  /// than all technically visible questions.
  bool get hasPendingBranchChange {
    for (final q in progressiveVisibleQuestions.whereType<FreeTextQuestion>()) {
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

  /// Determines which CTA to show for the given [questions].
  ///
  /// - [QuestionnaireCtaMode.hidden]: no question has an answer or non-empty
  ///   free-text draft.
  /// - [QuestionnaireCtaMode.continue_]: at least one free-text question has
  ///   a pending branch change.
  /// - [QuestionnaireCtaMode.complete]: every question has either a committed
  ///   answer or a non-empty free-text draft, and there is no pending branch
  ///   change.
  QuestionnaireCtaMode ctaModeFor(Iterable<Question> questions) {
    if (questions.isEmpty) return QuestionnaireCtaMode.hidden;

    var hasInput = false;
    for (final q in questions) {
      if (_answers.answers.containsKey(q.id)) {
        hasInput = true;
        break;
      }
      if (q is FreeTextQuestion) {
        final draft = _drafts[q.id];
        if (draft != null && draft.isNotEmpty) {
          hasInput = true;
          break;
        }
      }
    }

    if (!hasInput) return QuestionnaireCtaMode.hidden;

    if (hasPendingBranchChange) return QuestionnaireCtaMode.continue_;

    final allCovered = questions.every((q) {
      if (_answers.answers.containsKey(q.id)) return true;
      if (q is FreeTextQuestion) {
        final draft = _drafts[q.id];
        return draft != null && draft.isNotEmpty;
      }
      return false;
    });

    return allCovered
        ? QuestionnaireCtaMode.complete
        : QuestionnaireCtaMode.hidden;
  }

  /// Convenience getter that computes [ctaModeFor] for
  /// [progressiveVisibleQuestions].
  QuestionnaireCtaMode get ctaMode => ctaModeFor(progressiveVisibleQuestions);
}
