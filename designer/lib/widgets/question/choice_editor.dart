import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/widgets/util/helper.dart';

import '../buttons.dart';

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
            name: 'text',
            decoration: InputDecoration(labelText: AppLocalizations.of(context).choice),
            initialValue: widget.choice.text,
          ),
        ],
      ),
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.choice.text = _editFormKey.currentState.value['text'] as String;
        widget.choice.id = (_editFormKey.currentState.value['text'] as String).toId();
      });
    }
  }
}
