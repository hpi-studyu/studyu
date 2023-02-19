import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

class VisualAnalogueQuestionEditorSection extends StatefulWidget {
  final VisualAnalogueQuestion question;

  const VisualAnalogueQuestionEditorSection({@required this.question, Key key}) : super(key: key);

  @override
  _VisualAnalogueQuestionEditorSectionState createState() => _VisualAnalogueQuestionEditorSectionState();
}

class _VisualAnalogueQuestionEditorSectionState extends State<VisualAnalogueQuestionEditorSection> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();
  Color minimumColor;
  Color maximumColor;

  Widget colorPickerRow(String title, Color color, void Function(Color color) onSelect) {
    return ListTile(
      title: Text(title),
      trailing: ColorIndicator(
        color: color,
        onSelectFocus: false,
        hasBorder: true,
        borderRadius: 20,
        borderColor: const Color(0xFF000000),
        onSelect: () async {
          final Color newColor = await showColorPickerDialog(
            context,
            color,
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            width: 40,
            height: 40,
            spacing: 0,
            runSpacing: 0,
            borderRadius: 0,
            wheelDiameter: 165,
            enableOpacity: true,
            showColorCode: true,
            colorCodeHasColor: true,
            pickersEnabled: <ColorPickerType, bool>{
              ColorPickerType.wheel: true,
            },
            actionButtons: const ColorPickerActionButtons(
              okButton: true,
              closeButton: true,
              dialogActionButtons: false,
            ),
            constraints: const BoxConstraints(
              minHeight: 480,
              minWidth: 320,
              maxWidth: 320,
            ),
          );
          onSelect(newColor);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    minimumColor = Color(widget.question.minimumColor);
    maximumColor = Color(widget.question.maximumColor);

    return FormBuilder(
      key: _editFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // readonly: true,
      child: Column(
        children: <Widget>[
          FormBuilderTextField(
            onChanged: _saveFormChanges,
            name: 'minimumAnnotation',
            decoration: InputDecoration(labelText: AppLocalizations.of(context).minimum_annotation),
            initialValue: widget.question.minimumAnnotation,
          ),
          colorPickerRow(AppLocalizations.of(context).minimum_color, minimumColor, (Color newColor) {
            setState(() {
              minimumColor = newColor;
            });
            _saveFormChanges(null);
          }),
          FormBuilderTextField(
            onChanged: _saveFormChanges,
            name: 'maximumAnnotation',
            decoration: InputDecoration(labelText: AppLocalizations.of(context).maximum_annotation),
            initialValue: widget.question.maximumAnnotation,
          ),
          colorPickerRow(AppLocalizations.of(context).maximum_color, maximumColor, (Color newColor) {
            setState(() {
              maximumColor = newColor;
            });
            _saveFormChanges(null);
          }),
        ],
      ),
    );
  }

  void _saveFormChanges(value) {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.question.minimumAnnotation = _editFormKey.currentState.value['minimumAnnotation'] as String;
        widget.question.minimumColor = minimumColor.value;
        widget.question.maximumAnnotation = _editFormKey.currentState.value['maximumAnnotation'] as String;
        widget.question.maximumColor = maximumColor.value;
      });
    }
  }
}
