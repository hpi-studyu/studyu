import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/widgets/question_edit_widget.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

import '../../models/designer_state.dart';

class EligibilityDesigner extends StatefulWidget {
  @override
  _EligibilityDesignerState createState() => _EligibilityDesignerState();
}

class _EligibilityDesignerState extends State<EligibilityDesigner> {
  List<Question> _list;

  void _addItem(item) {
    setState(() {
      _list.add(item);
    });
  }

  void _addQuestion() {
    final question = BooleanQuestion()
      ..id = Uuid().v4()
      ..prompt = ''
      ..rationale = '';
    _addItem(question);
  }

  void _changeQuestionType(int index, String newType) {
    Question newQuestion;
    if (newType == BooleanQuestion.questionType) {
      newQuestion = BooleanQuestion();
    } else if (newType == ChoiceQuestion.questionType) {
      newQuestion = ChoiceQuestion()..choices = [];
    }
    newQuestion
      ..prompt = _list[index].prompt
      ..rationale = _list[index].rationale;
    setState(() {
      _list[index] = newQuestion;
    });
  }

  void _removeItem(index) {
    setState(() {
      _list.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    _list = context.watch<DesignerModel>().draftStudy.studyDetails.questionnaire.questions;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ..._list
                .asMap()
                .entries
                .map((entry) => QuestionEditWidget(
                    key: UniqueKey(),
                    remove: () => _removeItem(entry.key),
                    changeQuestionType: (newType) => _changeQuestionType(entry.key, newType),
                    question: entry.value))
                .toList(),
            RaisedButton.icon(
                textTheme: ButtonTextTheme.primary,
                onPressed: _addQuestion,
                icon: Icon(Icons.add),
                color: Colors.green,
                label: Text('Add Question'))
          ],
        ),
      ),
    );
  }
}
