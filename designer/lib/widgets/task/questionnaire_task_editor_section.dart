import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

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
      widget.task.questions.questions.add(BooleanQuestion.withId());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuestionnaireEditor(questionnaire: widget.task.questions, questionTypes: Question.questionTypes.keys.toList()),
        ElevatedButton.icon(
          onPressed: _addQuestion,
          icon: const Icon(Icons.add),
          style: ElevatedButton.styleFrom(primary: Colors.green),
          label: Text(AppLocalizations.of(context).add_question),
        )
      ],
    );
  }
}
