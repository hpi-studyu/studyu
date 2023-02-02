import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

import '../../widgets/question/question_editor.dart';

class QuestionnaireEditor extends StatefulWidget {
  final StudyUQuestionnaire questionnaire;
  final List<String> questionTypes;

  const QuestionnaireEditor({@required this.questionnaire, @required this.questionTypes, Key key}) : super(key: key);

  @override
  _QuestionnaireEditorState createState() => _QuestionnaireEditorState();
}

class _QuestionnaireEditorState extends State<QuestionnaireEditor> {
  void _removeQuestion(int index) {
    setState(() {
      widget.questionnaire.questions.removeAt(index);
    });
  }

  void _changeQuestionType(int index, String newType) {
    final oldQuestion = widget.questionnaire.questions[index];
    Question newQuestion;
    if (newType == BooleanQuestion.questionType) {
      newQuestion = BooleanQuestion.withId();
    } else if (newType == ChoiceQuestion.questionType) {
      newQuestion = ChoiceQuestion.withId();
    } else if (newType == AnnotatedScaleQuestion.questionType || newType == VisualAnalogueQuestion.questionType) {
      if (newType == AnnotatedScaleQuestion.questionType) {
        newQuestion = AnnotatedScaleQuestion.withId();
      } else {
        newQuestion = VisualAnalogueQuestion.withId();
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
        ...widget.questionnaire.questions.asMap().entries.map(
              (entry) => QuestionEditor(
                key: UniqueKey(),
                remove: () => _removeQuestion(entry.key),
                changeQuestionType: (newType) => _changeQuestionType(entry.key, newType),
                question: entry.value,
                questionTypes: widget.questionTypes,
              ),
            ),
      ],
    );
  }
}
