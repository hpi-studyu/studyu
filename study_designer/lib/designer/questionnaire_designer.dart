import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/questionnaire/questionnaire.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/designer_state.dart';
import '../widgets/question/questionnaire_editor.dart';
import '../widgets/util/designer_add_button.dart';

class EligibilityQuestionsDesigner extends StatefulWidget {
  @override
  _EligibilityQuestionsDesignerState createState() => _EligibilityQuestionsDesignerState();
}

class _EligibilityQuestionsDesignerState extends State<EligibilityQuestionsDesigner> {
  Questionnaire questionnaire;

  void _addQuestion() {
    setState(() {
      questionnaire.questions.add(BooleanQuestion.designerDefault());
    });
  }

  @override
  Widget build(BuildContext context) {
    questionnaire = context.watch<DesignerState>().draftStudy.studyDetails.questionnaire;
    return Stack(
      children: [
        Center(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: QuestionnaireEditor(
                      questionnaire: questionnaire,
                      questionTypes: [BooleanQuestion.questionType, ChoiceQuestion.questionType]),
                ))),
        DesignerAddButton(label: Text(AppLocalizations.of(context).add_question), add: _addQuestion),
      ],
    );
  }
}
