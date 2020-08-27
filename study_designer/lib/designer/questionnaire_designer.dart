import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/questionnaire/questionnaire.dart';

import '../models/designer_state.dart';
import '../widgets/question/questionnaire_editor.dart';
import '../widgets/util/designer_add_button.dart';

class QuestionnaireDesigner extends StatefulWidget {
  @override
  _QuestionnaireDesignerState createState() => _QuestionnaireDesignerState();
}

class _QuestionnaireDesignerState extends State<QuestionnaireDesigner> {
  Questionnaire questionnaire;

  void _addQuestion() {
    setState(() {
      questionnaire.questions.add(BooleanQuestion.designer());
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
        DesignerAddButton(label: Text('Add Question'), add: _addQuestion),
      ],
    );
  }
}
