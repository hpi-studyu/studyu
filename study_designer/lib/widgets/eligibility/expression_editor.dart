import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/expressions/types/value_expression.dart';
import 'package:studyou_core/models/models.dart';

class ExpressionEditor extends StatefulWidget {
  final ValueExpression expression;
  final List<Question> questions;
  final void Function(Question question) changeTarget;

  const ExpressionEditor({@required this.expression, @required this.questions, @required this.changeTarget, Key key})
      : super(key: key);

  @override
  _ExpressionEditorState createState() => _ExpressionEditorState();
}

class _ExpressionEditorState extends State<ExpressionEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              FormBuilder(
                  key: _editFormKey,
                  autovalidate: true,
                  // readonly: true,
                  child: Column(children: <Widget>[
                    FormBuilderDropdown(
                      name: 'target',
                      initialValue: widget.expression.target,
                      onChanged: (value) {
                        setState(() {
                          widget.expression.target = value.id;
                        });
                        widget.changeTarget(value);
                      },
                      decoration: InputDecoration(labelText: 'Target'),
                      // initialValue: 'Male',
                      hint: Text('Select Target'),
                      items: widget.questions
                          .map((question) => DropdownMenuItem(value: question.id, child: Text(question.prompt)))
                          .toList(),
                    ),
                  ]))
            ]))
      ]),
    );
  }
}
