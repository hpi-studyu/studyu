import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_designer/widgets/question/questionnaire_editor.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

class QuestionnaireTaskEditorSection extends StatefulWidget {
  final QuestionnaireTask task;

  const QuestionnaireTaskEditorSection({@required this.task, Key key}) : super(key: key);

  @override
  _QuestionnaireTaskEditorState createState() => _QuestionnaireTaskEditorState();
}

class _QuestionnaireTaskEditorState extends State<QuestionnaireTaskEditorSection> {
  void _addQuestion() {
    final question = BooleanQuestion()
      ..id = Uuid().v4()
      ..prompt = ''
      ..rationale = '';
    setState(() {
      widget.task.questions.questions.add(question);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      QuestionnaireEditor(questionnaire: widget.task.questions, questionTypes: Question.questionTypes.keys.toList()),
      RaisedButton.icon(
          onPressed: _addQuestion, icon: Icon(Icons.add), color: Colors.green, label: Text('Add Question'))
    ]);
  }
}
