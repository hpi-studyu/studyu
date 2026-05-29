import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/audio_recording_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/image_capturing_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/question_header.dart';
import 'package:studyu_app/widgets/questionnaire/questions/annotated_scale_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/boolean_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/choice_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/fitbit_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/free_text_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/pain_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/scale_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/visual_analogue_question_widget.dart';
import 'package:studyu_core/core.dart';

class QuestionContainer extends StatefulWidget {
  final Function(Answer, int) onDone;
  final Function(int)? onInvalid;
  final Question question;
  final int index;
  final String? taskId;
  final GlobalKey? containerKey;
  final bool isLastQuestion;
  final bool hasConditionalDependents;
  final Answer? initialAnswer;

  const QuestionContainer({
    required this.onDone,
    this.onInvalid,
    required this.question,
    required this.index,
    this.taskId,
    this.containerKey,
    this.isLastQuestion = true,
    this.hasConditionalDependents = false,
    this.initialAnswer,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => QuestionContainerState();
}

class QuestionValidationResult {
  final bool isValid;
  final BuildContext? invalidContext;

  const QuestionValidationResult.valid()
    : isValid = true,
      invalidContext = null;

  const QuestionValidationResult.invalid(this.invalidContext) : isValid = false;
}

class QuestionContainerState extends State<QuestionContainer>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FreeTextQuestionWidgetState> _freeTextKey =
      GlobalKey<FreeTextQuestionWidgetState>();

  void _onDone(Answer answer) {
    widget.onDone(answer, widget.index);
  }

  void _onInvalid() {
    widget.onInvalid?.call(widget.index);
  }

  QuestionWidget getQuestionBody(BuildContext context) {
    switch (widget.question) {
      case final ChoiceQuestion choiceQuestion:
        return ChoiceQuestionWidget(
          question: choiceQuestion,
          onDone: _onDone,
          initialAnswer: widget.initialAnswer as Answer<List<String>>?,
          multiSelectionText: AppLocalizations.of(
            context,
          )!.eligible_choice_multi_selection,
        );
      case final BooleanQuestion booleanQuestion:
        return BooleanQuestionWidget(
          question: booleanQuestion,
          onDone: _onDone,
          initialAnswer: widget.initialAnswer as Answer<bool>?,
        );
      case final ScaleQuestion scaleQuestion:
        return ScaleQuestionWidget(
          question: scaleQuestion,
          onDone: _onDone,
          initialAnswer: widget.initialAnswer as Answer<num>?,
        );
      case final ImageCapturingQuestion imageCapturingQuestion:
        // No initialAnswer until image widget can render restored captures.
        return ImageCapturingQuestionWidget(
          question: imageCapturingQuestion,
          onDone: _onDone,
        );
      case final AudioRecordingQuestion audioRecordingQuestion:
        // No initialAnswer until audio widget can render restored recordings.
        return AudioRecordingQuestionWidget(
          question: audioRecordingQuestion,
          onDone: _onDone,
        );
      case final VisualAnalogueQuestion visualAnalogueQuestion:
        // todo remove this when older studies are finished
        // ignore: deprecated_member_use_from_same_package
        return VisualAnalogueQuestionWidget(
          question: visualAnalogueQuestion,
          onDone: _onDone,
          initialAnswer: widget.initialAnswer as Answer<num>?,
        );
      case final AnnotatedScaleQuestion annotatedScaleQuestion:
        return AnnotatedScaleQuestionWidget(
          question: annotatedScaleQuestion,
          onDone: _onDone,
          initialAnswer: widget.initialAnswer as Answer<num>?,
        );
      case final FreeTextQuestion freeTextQuestion:
        return FreeTextQuestionWidget(
          key: _freeTextKey,
          question: freeTextQuestion,
          onDone: _onDone,
          onInvalid: _onInvalid,
          isLastQuestion: widget.isLastQuestion,
          hasConditionalDependents: widget.hasConditionalDependents,
          initialAnswer: widget.initialAnswer as Answer<String>?,
        );
      case final FitbitQuestion fitbitQuestion:
        // No initialAnswer until Fitbit widget can render restored values.
        return FitbitQuestionWidget(
          question: fitbitQuestion,
          onDone: _onDone,
          taskId: widget.taskId!,
        );
      case final PainQuestion painQuestion:
        // No initialAnswer until pain widget can render restored values.
        return PainQuestionWidget(question: painQuestion, onDone: _onDone);
      default:
        throw ArgumentError(
          'Question type ${widget.question.type} not supported',
        );
    }
  }

  QuestionValidationResult validateForComplete() {
    if (widget.question is FreeTextQuestion) {
      final freeTextState = _freeTextKey.currentState;
      final isValid = freeTextState?.validateForComplete() ?? false;
      if (!isValid) {
        return QuestionValidationResult.invalid(_freeTextKey.currentContext);
      }
    }
    return const QuestionValidationResult.valid();
  }

  Answer? syncForComplete() {
    if (widget.question is! FreeTextQuestion) return null;
    if (widget.hasConditionalDependents && !widget.isLastQuestion) return null;

    final freeTextState = _freeTextKey.currentState;
    final answer = freeTextState?.buildAnswerForComplete();
    if (answer != null) {
      freeTextState?.markSyncedForComplete();
    }
    return answer;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final questionBody = getQuestionBody(context);

    return Card(
      key: widget.containerKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionHeader(
              prompt: widget.question.prompt,
              subtitle: questionBody.subtitle,
              rationale: widget.question.rationale,
            ),
            const SizedBox(height: 24),
            questionBody,
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
