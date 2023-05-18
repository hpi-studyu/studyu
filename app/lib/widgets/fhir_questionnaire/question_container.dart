import 'package:fhir/r4.dart' as fhir;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'boolean_question_widget.dart';
import 'choice_question_widget.dart';
import 'question_header.dart';
import 'question_widget.dart';

class QuestionContainer extends StatelessWidget {
  final Function(fhir.QuestionnaireResponseItem, int) onDone;
  final fhir.QuestionnaireItem question;
  final int? index;

  const QuestionContainer({required this.onDone, required this.question, this.index, Key? key}) : super(key: key);

  void _onDone(fhir.QuestionnaireResponseItem response) {
    onDone(response, index!);
  }

  QuestionWidget? getQuestionBody(BuildContext context) {
    switch (question.type) {
      case fhir.QuestionnaireItemType.choice:
        return ChoiceQuestionWidget(
          question: question,
          onDone: _onDone,
          multiSelectionText: AppLocalizations.of(context)!.eligible_choice_multi_selection,
        );
      case fhir.QuestionnaireItemType.boolean:
        return BooleanQuestionWidget(
          question: question,
          onDone: _onDone,
        );
      // case VisualAnalogueQuestion:
      //   return VisualAnalogueQuestionWidget(
      //     question: question as VisualAnalogueQuestion,
      //     onDone: _onDone,
      //   );
      // case AnnotatedScaleQuestion:
      //   return AnnotatedScaleQuestionWidget(
      //     question: question as AnnotatedScaleQuestion,
      //     onDone: _onDone,
      //   );
      default:
        print('QuestionType: ${question.type} not supported!');
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionBody = getQuestionBody(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionHeader(
              prompt: question.text,
              subtitle: questionBody.subtitle,
              rationale: question.text,
            ),
            const SizedBox(height: 16),
            questionBody,
          ],
        ),
      ),
    );
  }
}
