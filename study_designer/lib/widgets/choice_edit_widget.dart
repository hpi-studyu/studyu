import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';

class ChoiceEditWidget extends StatefulWidget {
  final Choice choice;

  const ChoiceEditWidget({@required this.choice, Key key}) : super(key: key);

  @override
  _ChoiceEditWidgetState createState() => _ChoiceEditWidgetState();
}

class _ChoiceEditWidgetState extends State<ChoiceEditWidget> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: _editFormKey,
        autovalidate: true,
        // readonly: true,
        child: Column(children: <Widget>[
          FormBuilderTextField(
              validator: FormBuilderValidators.minLength(context, 3),
              onChanged: (value) {
                saveFormChanges();
              },
              attribute: 'text',
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
