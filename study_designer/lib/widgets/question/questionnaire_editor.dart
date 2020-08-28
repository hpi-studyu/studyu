import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/questionnaire/questionnaire.dart';
import 'package:studyou_core/models/questionnaire/questions/slider_question.dart';

import '../../widgets/question/question_editor.dart';

class QuestionnaireEditor extends StatefulWidget {
  final Questionnaire questionnaire;
  final List<String> questionTypes;

  const QuestionnaireEditor({@required this.questionnaire, @required this.questionTypes, Key key}) : super(key: key);

  @override
  _QuestionnaireEditorState createState() => _QuestionnaireEditorState();
}

class _QuestionnaireEditorState extends State<QuestionnaireEditor> {
  void _removeQuestion(index) {
    setState(() {
      widget.questionnaire.questions.removeAt(index);
    });
  }

  void _changeQuestionType(int index, String newType) {
    final oldQuestion = widget.questionnaire.questions[index];
    Question newQuestion;
    if (newType == BooleanQuestion.questionType) {
      newQuestion = BooleanQuestion.designerDefault();
    } else if (newType == ChoiceQuestion.questionType) {
      newQuestion = ChoiceQuestion.designerDefault();
    } else if (newType == AnnotatedScaleQuestion.questionType || newType == VisualAnalogueQuestion.questionType) {
      if (newType == AnnotatedScaleQuestion.questionType) {
        newQuestion = AnnotatedScaleQuestion.designerDefault();
      } else {
        newQuestion = VisualAnalogueQuestion.designerDefault();
      }
      if (newQuestion is SliderQuestion) {
        if (oldQuestion is SliderQuestion) {
          newQuestion
            ..minimum = oldQuestion.minimum
            ..maximum = oldQuestion.maximum
            ..initial = oldQuestion.initial
            ..step = oldQuestion.step;
        }
      }
    }
    newQuestion
      ..prompt = oldQuestion.prompt
      ..rationale = oldQuestion.rationale;
    setState(() {
      widget.questionnaire.questions[index] = newQuestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ...widget.questionnaire.questions
            .asMap()
            .entries
            .map(
              (entry) => QuestionEditor(
                  key: UniqueKey(),
                  remove: () => _removeQuestion(entry.key),
                  changeQuestionType: (newType) => _changeQuestionType(entry.key, newType),
                  question: entry.value,
                  questionTypes: widget.questionTypes),
            )
            .toList(),
      ],
    );
  }
}
