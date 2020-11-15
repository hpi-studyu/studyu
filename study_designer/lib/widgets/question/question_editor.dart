import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/question/choice_question_editor_section.dart';
import '../../widgets/question/slider_question_editor_section.dart';

class QuestionEditor extends StatefulWidget {
  final Question question;
  final List<String> questionTypes;
  final void Function() remove;
  final void Function(String newType) changeQuestionType;

  const QuestionEditor(
      {@required this.question,
      @required this.questionTypes,
      @required this.remove,
      @required this.changeQuestionType,
      Key key})
      : super(key: key);

  @override
  _QuestionEditorState createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final questionBody = _buildQuestionBody();

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
              title: Row(
                children: [
                  DropdownButton<String>(
                    value: widget.question.type,
                    onChanged: widget.changeQuestionType,
                    items: widget.questionTypes.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('${value[0].toUpperCase()}${value.substring(1)}'),
                      );
                    }).toList(),
                  ),
                  Text(AppLocalizations.of(context).question)
                ],
              ),
              trailing: FlatButton(
                onPressed: widget.remove,
                child: Text(AppLocalizations.of(context).delete),
              )),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                FormBuilder(
                    key: _editFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    // readonly: true,
                    child: Column(children: <Widget>[
                      FormBuilderTextField(
                          onChanged: (value) {
                            _saveFormChanges();
                          },
                          name: 'prompt',
                          decoration: InputDecoration(labelText: AppLocalizations.of(context).prompt),
                          initialValue: widget.question.prompt),
                      FormBuilderTextField(
                          onChanged: (value) {
                            _saveFormChanges();
                          },
                          name: 'rationale',
                          decoration: InputDecoration(labelText: AppLocalizations.of(context).rationale),
                          initialValue: widget.question.rationale),
                    ])),
                if (questionBody != null) questionBody
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBody() {
    switch (widget.question.runtimeType) {
      case ChoiceQuestion:
        return ChoiceQuestionEditorSection(
          question: widget.question,
        );
      case VisualAnalogueQuestion:
      case AnnotatedScaleQuestion:
        return SliderQuestionEditorSection(question: widget.question);
      default:
        return null;
    }
  }

  void _saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.question.prompt = _editFormKey.currentState.value['prompt'];
        widget.question.rationale = _editFormKey.currentState.value['rationale'];
      });
    }
  }
}
