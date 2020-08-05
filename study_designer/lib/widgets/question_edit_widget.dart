import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_designer/widgets/choice_question_edit_widget.dart';
import 'package:studyou_core/models/models.dart';

class QuestionEditWidget extends StatefulWidget {
  final Question question;

  const QuestionEditWidget({@required this.question, Key key}) : super(key: key);

  @override
  _QuestionEditWidgetState createState() => _QuestionEditWidgetState();
}

class _QuestionEditWidgetState extends State<QuestionEditWidget> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final questionBody = buildQuestionBody();

    return Column(
      children: [
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
                  name: 'prompt',
                  decoration: InputDecoration(labelText: 'Prompt'),
                  initialValue: widget.question.prompt),
              FormBuilderTextField(
                  validator: FormBuilderValidators.minLength(context, 3),
                  onChanged: (value) {
                    saveFormChanges();
                  },
                  name: 'rationale',
                  decoration: InputDecoration(labelText: 'Rationale'),
                  initialValue: widget.question.rationale),
            ])),
        if (questionBody != null) questionBody
      ],
    );
  }

  Widget buildQuestionBody() {
    switch (widget.question.runtimeType) {
      case ChoiceQuestion:
        return ChoiceQuestionEditWidget(
          question: widget.question,
        );
      default:
        print('Question not supported!');
        return null;
    }
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.question.prompt = _editFormKey.currentState.value['prompt'];
        widget.question.rationale = _editFormKey.currentState.value['rationale'];
      });
    }
  }
}
