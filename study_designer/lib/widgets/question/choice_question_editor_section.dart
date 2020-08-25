import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

import 'choice_editor.dart';

class ChoiceQuestionEditorSection extends StatefulWidget {
  final ChoiceQuestion question;

  const ChoiceQuestionEditorSection({@required this.question, Key key}) : super(key: key);

  @override
  _ChoiceQuestionEditorSectionState createState() => _ChoiceQuestionEditorSectionState();
}

class _ChoiceQuestionEditorSectionState extends State<ChoiceQuestionEditorSection> {
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
      Row(children: [
        Text('Multiple:'),
        SizedBox(width: 10),
        Switch(
          value: widget.question.multiple,
          onChanged: (value) {
            setState(() {
              widget.question.multiple = value;
            });
          },
        )
      ]),
      ListView.builder(
        shrinkWrap: true,
        itemCount: widget.question.choices.length,
        itemBuilder: (buildContext, index) {
          return ChoiceEditor(
              key: UniqueKey(), choice: widget.question.choices[index], remove: () => _removeChoice(index));
        },
      ),
      Row(children: [
        Spacer(),
        RaisedButton.icon(onPressed: _addChoice, icon: Icon(Icons.add), color: Colors.green, label: Text('Add Choice')),
        Spacer()
      ])
    ]);
  }
}
