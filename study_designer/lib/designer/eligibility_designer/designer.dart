import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/questionnaire/questionnaire.dart';
import 'package:uuid/uuid.dart';

import '../../models/designer_state.dart';
import '../../widgets/designer_add_button.dart';
import '../../widgets/question/questionnaire_editor.dart';

class EligibilityDesigner extends StatefulWidget {
  @override
  _EligibilityDesignerState createState() => _EligibilityDesignerState();
}

class _EligibilityDesignerState extends State<EligibilityDesigner> {
  Questionnaire questionnaire;

  void _addQuestion() {
    final question = BooleanQuestion()
      ..id = Uuid().v4()
      ..prompt = ''
      ..rationale = '';
    setState(() {
      questionnaire.questions.add(question);
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
