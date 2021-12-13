import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/widgets/buttons.dart';

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
      child: Column(
        children: <Widget>[
          ButtonBar(
            children: <Widget>[
              DeleteButton(onPressed: widget.remove),
            ],
          ),
          FormBuilderTextField(
            onChanged: (value) {
              saveFormChanges();
            },
            name: 'value',
            decoration: InputDecoration(labelText: AppLocalizations.of(context).value),
            initialValue: widget.annotation.value.toString(),
          ),
          FormBuilderTextField(
            onChanged: (value) {
              saveFormChanges();
            },
            name: 'annotation',
            decoration: InputDecoration(labelText: AppLocalizations.of(context).annotation),
            initialValue: widget.annotation.annotation,
          ),
        ],
      ),
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.annotation.value = int.parse(_editFormKey.currentState.value['value'] as String);
        widget.annotation.annotation = _editFormKey.currentState.value['annotation'] as String;
      });
    }
  }
}
