import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

class AnnotationEditor extends StatefulWidget {
  final Annotation annotation;
  final void Function() remove;

  const AnnotationEditor({@required this.annotation, @required this.remove, Key key}) : super(key: key);

  @override
  _AnnotationEditorState createState() => _AnnotationEditorState();
}

class _AnnotationEditorState extends State<AnnotationEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: _editFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // readonly: true,
        child: Column(children: <Widget>[
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: widget.remove,
                child: Text(Nof1Localizations.of(context).translate('delete')),
              ),
            ],
          ),
          FormBuilderTextField(
              onChanged: (value) {
                saveFormChanges();
              },
              name: 'value',
              decoration: InputDecoration(labelText: Nof1Localizations.of(context).translate('value')),
              initialValue: widget.annotation.value.toString()),
          FormBuilderTextField(
              onChanged: (value) {
                saveFormChanges();
              },
              name: 'annotation',
              decoration: InputDecoration(labelText: Nof1Localizations.of(context).translate('annotation')),
              initialValue: widget.annotation.annotation),
        ]));
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.annotation.value = int.parse(_editFormKey.currentState.value['value']);
        widget.annotation.annotation = _editFormKey.currentState.value['annotation'];
      });
    }
  }
}
