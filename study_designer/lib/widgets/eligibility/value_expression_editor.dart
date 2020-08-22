import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/expressions/types/boolean_expression.dart';
import 'package:studyou_core/models/expressions/types/choice_expression.dart';
import 'package:studyou_core/models/expressions/types/value_expression.dart';
import 'package:studyou_core/models/models.dart';

import './choice_expression_editor_section.dart';

class ValueExpressionEditor extends StatefulWidget {
  final ValueExpression expression;
  final List<Question> questions;
  final void Function(Expression newExpression) updateExpression;

  const ValueExpressionEditor(
      {@required this.expression, @required this.questions, @required this.updateExpression, Key key})
      : super(key: key);

  @override
  _ValueExpressionEditorState createState() => _ValueExpressionEditorState();
}

class _ValueExpressionEditorState extends State<ValueExpressionEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();
  Question targetQuestion;

  @override
  void initState() {
    if (widget.expression.target != null) {
      targetQuestion = widget.questions.where((q) => q.id == widget.expression.target).toList()[0];
    } else {
      targetQuestion = null;
    }
    super.initState();
  }

  void _changeExpressionTarget(Question newTarget) {
    ValueExpression newExpression;
    if (newTarget is BooleanQuestion) {
      newExpression = BooleanExpression();
    } else if (newTarget is ChoiceQuestion) {
      final newChoiceExpression = ChoiceExpression()..choices = {};
      newExpression = newChoiceExpression;
    }
    newExpression.target = newTarget.id;
    widget.updateExpression(newExpression);
  }

  @override
  Widget build(BuildContext context) {
    final expressionBody = _buildExpressionBody();

    return Column(children: [
      FormBuilder(
          key: _editFormKey,
          autovalidate: true,
          // readonly: true,
          child: Column(children: <Widget>[
            FormBuilderDropdown(
              name: 'target',
              initialValue: targetQuestion,
              onChanged: (question) {
                setState(() {
                  targetQuestion = question;
                });
                _changeExpressionTarget(question);
              },
              decoration: InputDecoration(labelText: 'Target'),
              // initialValue: 'Male',
              hint: Text('Select Target'),
              items: widget.questions
                  .map((question) => DropdownMenuItem(value: question, child: Text(question.prompt)))
                  .toList(),
            ),
          ])),
      if (expressionBody != null) expressionBody
    ]);
  }

  Widget _buildExpressionBody() {
    switch (widget.expression.runtimeType) {
      case ChoiceExpression:
        return ChoiceExpressionEditorSection(expression: widget.expression, targetQuestion: targetQuestion);
      default:
        return null;
    }
  }
}
