import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/legacy/designer/app_state.dart';

import '../../widgets/study_result/numeric_result_editor_section.dart';
import '../buttons.dart';

class StudyResultEditor extends StatefulWidget {
  final StudyResult result;
  final void Function() remove;
  final void Function(String? newType) changeResultType;

  const StudyResultEditor({required this.result, required this.remove, required this.changeResultType, Key? key})
      : super(key: key);

  @override
  _StudyResultEditorState createState() => _StudyResultEditorState();
}

class _StudyResultEditorState extends State<StudyResultEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final questionBody = _buildResultBody();

    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                DropdownButton<String>(
                  value: widget.result.type,
                  onChanged: widget.changeResultType,
                  items: StudyResult.studyResultTypes.keys.map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('${value[0].toUpperCase()}${value.substring(1)}'),
                    );
                  }).toList(),
                ),
                Text(AppLocalizations.of(context)!.result)
              ],
            ),
            trailing: DeleteButton(onPressed: widget.remove),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                FormBuilder(
                  key: _editFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  // readonly: true,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        onChanged: (value) {
                          _saveFormChanges();
                        },
                        name: 'filename',
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.filename),
                        initialValue: widget.result.filename,
                      ),
                    ],
                  ),
                ),
                if (questionBody != null) questionBody
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildResultBody() {
    switch (widget.result.runtimeType) {
      case NumericResult:
        return NumericResultEditorSection(result: widget.result as NumericResult);
      default:
        return null;
    }
  }

  void _saveFormChanges() {
    _editFormKey.currentState!.save();
    if (_editFormKey.currentState!.validate()) {
      setState(() {
        widget.result.filename = _editFormKey.currentState!.value['filename'] as String;
      });
      context.read<AppState>().updateDelegate();
    }
  }
}
