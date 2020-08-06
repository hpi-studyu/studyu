import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/widgets/designer_add_button.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

import '../../models/designer_state.dart';
import '../../widgets/question_edit_widget.dart';

class EligibilityDesigner extends StatefulWidget {
  @override
  _EligibilityDesignerState createState() => _EligibilityDesignerState();
}

class _EligibilityDesignerState extends State<EligibilityDesigner> {
  List<Question> _questions;

  void _addQuestion() {
    final question = BooleanQuestion()
      ..id = Uuid().v4()
      ..prompt = ''
      ..rationale = '';
    setState(() {
      _questions.add(question);
    });
  }

  void _removeQuestion(index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _changeQuestionType(int index, String newType) {
    Question newQuestion;
    if (newType == BooleanQuestion.questionType) {
      newQuestion = BooleanQuestion();
    } else if (newType == ChoiceQuestion.questionType) {
      newQuestion = ChoiceQuestion()..choices = [];
    }
    newQuestion
      ..prompt = _questions[index].prompt
      ..rationale = _questions[index].rationale;
    setState(() {
      _questions[index] = newQuestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    _questions = context.watch<DesignerModel>().draftStudy.studyDetails.questionnaire.questions;
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ..._questions
                      .asMap()
                      .entries
                      .map((entry) => QuestionEditWidget(
                          key: UniqueKey(),
                          remove: () => _removeQuestion(entry.key),
                          changeQuestionType: (newType) => _changeQuestionType(entry.key, newType),
                          question: entry.value))
                      .toList(),
                ],
              ),
            ),
          ),
        ),
        DesignerAddButton(label: Text('Add Question'), add: _addQuestion),
      ],
    );
  }
}
