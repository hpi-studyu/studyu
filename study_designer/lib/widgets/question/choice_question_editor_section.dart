import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

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
      FormBuilder(
          key: _editFormKey,
          autovalidate: true,
          // readonly: true,
          child: Column(children: <Widget>[
            FormBuilderSwitch(
              onChanged: _saveFormChanges,
              title: Text('Multiple'),
              name: 'multiple',
              initialValue: widget.question.multiple,
            ),
          ])),
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

  void _saveFormChanges(value) {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.question.multiple = _editFormKey.currentState.value['multiple'];
      });
    }
  }
}
