import 'dart:async';

import 'package:fhir/r4.dart' as fhir;
import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';

import 'question_container.dart';

typedef StateHandler = void Function(QuestionnaireState);
typedef ContinuationPredicate = bool Function(QuestionnaireState);

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
  final QuestionnaireState qs = QuestionnaireState(); // equivalent to QuestionnaireResponse
  fhir.QuestionnaireResponse questionnaireResponse;

  void _finishQuestionnaire() => widget.onComplete?.call(qs);

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

    widget.onChange?.call(qs);
    if (widget.questionnaire.item.length > shownQuestions.length) {
      if (!(widget.shouldContinue?.call(qs) ?? true)) return;
      // TODO: Check if next question should be show based on answer of previous question (FHIR Questionnaire Pane)
      // if (!widget.questionnaire.item[_nextQuestionIndex].shouldBeShown(qs)) {
      //   _onQuestionDone(widget.questionnaire.item[_nextQuestionIndex].getDefaultAnswer(), shownQuestions.length);
      //   return;
      // }
      _insertQuestion(widget.questionnaire.item[shownQuestions.length]);
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
