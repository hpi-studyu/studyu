import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';

class ChoiceEditor extends StatefulWidget {
  final Choice choice;
  final void Function() remove;

  const ChoiceEditor({@required this.choice, @required this.remove, Key key}) : super(key: key);

  @override
  _ChoiceEditorState createState() => _ChoiceEditorState();
}

class _ChoiceEditorState extends State<ChoiceEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: _editFormKey,
        autovalidate: true,
        // readonly: true,
        child: Column(children: <Widget>[
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: widget.remove,
                child: const Text('Delete'),
              ),
            ],
          ),
          FormBuilderTextField(
              onChanged: (value) {
                saveFormChanges();
              },
              name: 'text',
              decoration: InputDecoration(labelText: 'Choice'),
              initialValue: widget.choice.text),
        ]));
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.choice.text = _editFormKey.currentState.value['text'];
      });
    }
  }
}
