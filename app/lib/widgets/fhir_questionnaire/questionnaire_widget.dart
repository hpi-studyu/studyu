import 'dart:async';

import 'package:fhir/r4.dart' as fhir;
import 'package:flutter/material.dart';

import 'question_container.dart';

typedef StateHandler = void Function(fhir.QuestionnaireResponse);
typedef ContinuationPredicate = bool Function(fhir.QuestionnaireResponse);

class FhirQuestionnaireWidget extends StatefulWidget {
  final String title;
  final fhir.Questionnaire questionnaire;
  final StateHandler onChange;
  final StateHandler onComplete;
  final ContinuationPredicate shouldContinue;

  const FhirQuestionnaireWidget(this.questionnaire,
      {this.title, this.onComplete, this.onChange, this.shouldContinue, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FhirQuestionnaireWidgetState();
}

class _FhirQuestionnaireWidgetState extends State<FhirQuestionnaireWidget> {
  final List<QuestionContainer> shownQuestions = <QuestionContainer>[];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();

  // Map of question -> Answer
  // Answer can have type bool, num(int,double), String, List<String>
  // Only bool and num are currently used and List<String> (choice, only used for eligibility)
  fhir.QuestionnaireResponse questionnaireResponse;

  void _finishQuestionnaire() => widget.onComplete?.call(questionnaireResponse);

  /// Removes responses of clicked question and all following questions
  void _invalidateDownstreamAnswers(int index) {
    if (index < shownQuestions.length - 1) {
      questionnaireResponse.item.removeRange(index, questionnaireResponse.item.length);
      while (index + 1 < shownQuestions.length) {
        final end = shownQuestions.length - 1;
        final lastQuestion = shownQuestions.removeLast();
        _listKey.currentState.removeItem(
            end,
            (context, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: lastQuestion,
                ));
      }
    }
  }

  void _insertQuestion(fhir.QuestionnaireItem question) {
    shownQuestions.add(QuestionContainer(
      question: question,
      onDone: _onQuestionDone,
      index: shownQuestions.length,
    ));
  }

  void _onQuestionDone(fhir.QuestionnaireResponseItem newResponseItem, int index) {
    _invalidateDownstreamAnswers(index);

    final oldResponseIndex =
        questionnaireResponse.item?.indexWhere((item) => item.linkId == newResponseItem.linkId) ?? -1;
    if (oldResponseIndex > -1) {
      questionnaireResponse.item[oldResponseIndex] = newResponseItem;
    } else {
      questionnaireResponse.item.add(newResponseItem);
    }

    widget.onChange?.call(questionnaireResponse);
    final nextQuestion = _nextQuestion();
    print(nextQuestion);
    if (nextQuestion != null) {
      if (!(widget.shouldContinue?.call(questionnaireResponse) ?? true)) {
        return; // Checks if answer is wrong => not eligible ==> VALIDATION OF ANSWERS GIVEN!
      }
      _insertQuestion(nextQuestion);
      _listKey.currentState.insertItem(shownQuestions.length - 1, duration: Duration(milliseconds: 300));

      // Scroll to bottom
      Timer(
        Duration(milliseconds: 300),
        () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        },
      );
    } else {
      _finishQuestionnaire();
    }
  }

  fhir.QuestionnaireItem _nextQuestion() {
    // TODO: Use Map<linkId, QuestionnaireItem> to not iterate over all questions
    return widget.questionnaire.item
        .firstWhere((item) => isQuestionNotDisplayedYet(item) && isQuestionEnabled(item), orElse: () => null);
  }

  bool isQuestionNotDisplayedYet(fhir.QuestionnaireItem item) {
    return shownQuestions.every((question) => question.question.linkId != item.linkId);
  }

  bool isQuestionEnabled(fhir.QuestionnaireItem item) {
    if (item.enableWhen == null || item.enableWhen.isEmpty) return true;

    switch (item.enableBehavior) {
      case fhir.QuestionnaireItemEnableBehavior.all:
        return item.enableWhen.every(_satisfies);
      case fhir.QuestionnaireItemEnableBehavior.any:
        return item.enableWhen.any(_satisfies);
      default:
        return true;
    }
  }

  bool _satisfies(fhir.QuestionnaireEnableWhen condition) {
    final conditionalItem =
        questionnaireResponse.item?.firstWhere((item) => item.linkId == condition.question, orElse: () => null);
    switch (condition.operator_) {
      case fhir.QuestionnaireEnableWhenOperator.exists:
        if (conditionalItem == null) {
          return false;
        }
        break;
      case fhir.QuestionnaireEnableWhenOperator.eq:
        final responseCoding = conditionalItem?.answer?.first?.valueCoding;
        if (responseCoding?.code != condition.answerCoding?.code) {
          return false;
        }
        break;
      default:
        print('Unsupported operator: ${condition.operator_}.');
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    questionnaireResponse = fhir.QuestionnaireResponse(
      questionnaire: fhir.Canonical(widget.questionnaire.url?.value ?? ''),
      status: fhir.QuestionnaireResponseStatus.in_progress,
      item: [],
    );
    _insertQuestion(widget.questionnaire.item.first);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      controller: _scrollController,
      initialItemCount: 1,
      itemBuilder: (context, index, animation) {
        return shownQuestions[index];
      },
    );
  }
}
