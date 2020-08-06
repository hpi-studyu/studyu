import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

import 'choice_edit_widget.dart';

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
    /*return Column(children: [
      RaisedButton.icon(onPressed: _addChoice, icon: Icon(Icons.add), color: Colors.green, label: Text('Add Choice')),
      ...widget.question.choices.asMap().entries.map(
          (entry) => ChoiceEditWidget(key: UniqueKey(), choice: entry.value, remove: () => _removeChoice(entry.key)))
    ]);*/
    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        itemCount: widget.question.choices.length + 1,
        itemBuilder: (buildContext, index) {
          return index == widget.question.choices.length
              ? Row(children: [
                  Spacer(),
                  RaisedButton.icon(
                      onPressed: _addChoice, icon: Icon(Icons.add), color: Colors.green, label: Text('Add Choice')),
                  Spacer()
                ])
              : ChoiceEditWidget(
                  key: UniqueKey(), choice: widget.question.choices[index], remove: () => _removeChoice(index));
        },
      )
    ]);
  }
}
