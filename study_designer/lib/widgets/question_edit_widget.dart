import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';

class QuestionEditWidget extends StatefulWidget {
  final Question item;
  final void Function() remove;

  const QuestionEditWidget({@required this.item, @required this.remove, Key key}) : super(key: key);

  @override
  _QuestionEditWidgetState createState() => _QuestionEditWidgetState();
}

class _QuestionEditWidgetState extends State<QuestionEditWidget> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ButtonBar(
        children: <Widget>[
          FlatButton(
            onPressed: () {
              widget.remove();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
      FormBuilder(
          key: _editFormKey,
          autovalidate: true,
          // readonly: true,
          child: Column(children: <Widget>[
            FormBuilderTextField(
                validator: FormBuilderValidators.minLength(context, 3),
                onChanged: (value) {
                  saveFormChanges();
                },
                attribute: 'prompt',
                decoration: InputDecoration(labelText: 'Prompt'),
                initialValue: widget.item.prompt),
            FormBuilderTextField(
                validator: FormBuilderValidators.minLength(context, 3),
                onChanged: (value) {
                  saveFormChanges();
                },
                attribute: 'rationale',
                decoration: InputDecoration(labelText: 'Rationale'),
                initialValue: widget.item.rationale),
          ])),
    ]);
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.item.prompt = _editFormKey.currentState.value['prompt'];
        widget.item.rationale = _editFormKey.currentState.value['rationale'];
      });
    }
  }
}
