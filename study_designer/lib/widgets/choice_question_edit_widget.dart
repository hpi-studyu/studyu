import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_designer/widgets/choice_edit_widget.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

class ChoiceQuestionEditWidget extends StatefulWidget {
  final ChoiceQuestion question;

  const ChoiceQuestionEditWidget({@required this.question, Key key}) : super(key: key);

  @override
  _ChoiceQuestionEditWidgetState createState() => _ChoiceQuestionEditWidgetState();
}

class _ChoiceQuestionEditWidgetState extends State<ChoiceQuestionEditWidget> {
  void _addChoice() {
    setState(() {
      final choice = Choice()
        ..id = Uuid().v4()
        ..text = '';
      widget.question.choices.add(choice);
    });
  }

  void _removeChoice(index) {
    setState(() {
      widget.question.choices.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      RaisedButton.icon(onPressed: _addChoice, icon: Icon(Icons.add), color: Colors.green, label: Text('Add Choice')),
      ...widget.question.choices
          .asMap()
          .entries
          .map((entry) => ChoiceEditWidget(choice: entry.value, remove: () => _removeChoice(entry.key)))
    ]);
  }
}
