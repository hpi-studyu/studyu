import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';

class VisualAnalogueQuestionEditorSection extends StatefulWidget {
  final VisualAnalogueQuestion question;

  const VisualAnalogueQuestionEditorSection({@required this.question, Key key}) : super(key: key);

  @override
  _VisualAnalogueQuestionEditorSectionState createState() => _VisualAnalogueQuestionEditorSectionState();
}

class _VisualAnalogueQuestionEditorSectionState extends State<VisualAnalogueQuestionEditorSection> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: _editFormKey,
        autovalidate: true,
        // readonly: true,
        child: Column(children: <Widget>[
          FormBuilderTextField(
              onChanged: _saveFormChanges,
              name: 'minimumAnnotation',
              decoration: InputDecoration(labelText: 'Minimum Annotation'),
              initialValue: widget.question.minimumAnnotation),
          FormBuilderColorPickerField(
              onChanged: _saveFormChanges,
              name: 'minimumColor',
              showCursor: true,
              decoration: InputDecoration(labelText: 'Minimum Color'),
              initialValue: widget.question.minimumColor),
          FormBuilderTextField(
              onChanged: _saveFormChanges,
              name: 'maximumAnnotation',
              decoration: InputDecoration(labelText: 'Maximum Annotation'),
              initialValue: widget.question.maximumAnnotation),
          FormBuilderColorPickerField(
              onChanged: _saveFormChanges,
              name: 'maximumColor',
              showCursor: true,
              decoration: InputDecoration(labelText: 'Maximum Color'),
              initialValue: widget.question.maximumColor)
        ]));
  }

  void _saveFormChanges(value) {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.question.minimumColor = _editFormKey.currentState.value['minimumColor'];
      });
    }
  }
}
