import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/scale_question_widget.dart';
import 'package:studyu_core/core.dart';

import 'annotated_scale_question_widget.dart';
import 'boolean_question_widget.dart';
import 'choice_question_widget.dart';
import 'question_header.dart';
import 'question_widget.dart';
import 'visual_analogue_question_widget.dart';

class QuestionContainer extends StatelessWidget {
  final Function(Answer, int) onDone;
  final Question question;
  final int index;

  const QuestionContainer({@required this.onDone, @required this.question, this.index, Key key}) : super(key: key);

  void _onDone(Answer answer) {
    onDone(answer, index);
  }

  QuestionWidget getQuestionBody(BuildContext context) {
    switch (question.runtimeType) {
      case ChoiceQuestion:
        return ChoiceQuestionWidget(
          question: question as ChoiceQuestion,
          onDone: _onDone,
          multiSelectionText: AppLocalizations.of(context).eligible_choice_multi_selection,
        );
      case BooleanQuestion:
        return BooleanQuestionWidget(
          question: question as BooleanQuestion,
          onDone: _onDone,
        );
      case ScaleQuestion:
        return ScaleQuestionWidget(
          question: question as ScaleQuestion,
          onDone: _onDone,
        );
      case VisualAnalogueQuestion:
        return VisualAnalogueQuestionWidget(
          question: question as VisualAnalogueQuestion,
          onDone: _onDone,
        );
      case AnnotatedScaleQuestion:
        return AnnotatedScaleQuestionWidget(
          question: question as AnnotatedScaleQuestion,
          onDone: _onDone,
        );
      default:
        print('Question not supported!');
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionBody = getQuestionBody(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionHeader(
              prompt: question.prompt,
              subtitle: questionBody.subtitle,
              rationale: question.rationale,
            ),
            const SizedBox(height: 24),
            questionBody,
          ],
        ),
      ),
    );
  }
}
