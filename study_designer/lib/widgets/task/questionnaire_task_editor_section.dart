import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/question/questionnaire_editor.dart';

class QuestionnaireTaskEditorSection extends StatefulWidget {
  final QuestionnaireTask task;

  const QuestionnaireTaskEditorSection({@required this.task, Key key}) : super(key: key);

  @override
  _QuestionnaireTaskEditorState createState() => _QuestionnaireTaskEditorState();
}

class _QuestionnaireTaskEditorState extends State<QuestionnaireTaskEditorSection> {
  void _addQuestion() {
    setState(() {
      widget.task.questions.questions.add(BooleanQuestion.designerDefault());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      QuestionnaireEditor(questionnaire: widget.task.questions, questionTypes: Question.questionTypes.keys.toList()),
      RaisedButton.icon(
          onPressed: _addQuestion,
          icon: Icon(Icons.add),
          color: Colors.green,
          label: Text(AppLocalizations.of(context).add_question))
    ]);
  }
}
