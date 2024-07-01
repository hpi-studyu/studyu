import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/audio_recording_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/image_capturing_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/question_header.dart';
import 'package:studyu_app/widgets/questionnaire/questions/annotated_scale_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/boolean_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/choice_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/free_text_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/scale_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/visual_analogue_question_widget.dart';
import 'package:studyu_core/core.dart';

class QuestionContainer extends StatefulWidget {
  final Function(Answer, int) onDone;
  final Question question;
  final int index;

  const QuestionContainer({
    required this.onDone,
    required this.question,
    required this.index,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _QuestionContainerState();
}

class _QuestionContainerState extends State<QuestionContainer>
    with AutomaticKeepAliveClientMixin {
  void _onDone(Answer answer) {
    widget.onDone(answer, widget.index);
  }

  QuestionWidget getQuestionBody(BuildContext context) {
    switch (widget.question) {
      case final ChoiceQuestion choiceQuestion:
        return ChoiceQuestionWidget(
          question: choiceQuestion,
          onDone: _onDone,
          multiSelectionText:
              AppLocalizations.of(context)!.eligible_choice_multi_selection,
        );
      case final BooleanQuestion booleanQuestion:
        return BooleanQuestionWidget(
          question: booleanQuestion,
          onDone: _onDone,
        );
      case final ScaleQuestion scaleQuestion:
        return ScaleQuestionWidget(
          question: scaleQuestion,
          onDone: _onDone,
        );
      case final ImageCapturingQuestion imageCapturingQuestion:
        return ImageCapturingQuestionWidget(
          question: imageCapturingQuestion,
          onDone: _onDone,
        );
      case final AudioRecordingQuestion audioRecordingQuestion:
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
        );
      case final AnnotatedScaleQuestion annotatedScaleQuestion:
        return AnnotatedScaleQuestionWidget(
          question: annotatedScaleQuestion,
          onDone: _onDone,
        );
      case final FreeTextQuestion freeTextQuestion:
        return FreeTextQuestionWidget(
          question: freeTextQuestion,
          onDone: _onDone,
        );
      default:
        throw ArgumentError(
          'Question type ${widget.question.type} not supported',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final questionBody = getQuestionBody(context);

    return Card(
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
