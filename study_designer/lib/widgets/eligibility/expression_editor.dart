import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/expressions/types/boolean_expression.dart';
import 'package:studyou_core/models/expressions/types/choice_expression.dart';
import 'package:studyou_core/models/expressions/types/not_expression.dart';
import 'package:studyou_core/models/expressions/types/value_expression.dart';
import 'package:studyou_core/models/models.dart';

import './not_expression_editor.dart';
import './value_expression_editor.dart';

class ExpressionEditor extends StatefulWidget {
  final Expression expression;
  final List<Question> questions;
  final void Function(Expression newExpression) updateExpression;

  const ExpressionEditor(
      {@required this.expression, @required this.questions, @required this.updateExpression, Key key})
      : super(key: key);

  @override
  _ExpressionEditorState createState() => _ExpressionEditorState();
}

class _ExpressionEditorState extends State<ExpressionEditor> {
  void _changeExpressionType(String newType) {
    Expression newExpression;

    if (newType == BooleanExpression.expressionType || newType == ValueExpression.expressionType) {
      newExpression = BooleanExpression();
    } else if (newType is ChoiceQuestion) {
      newExpression = ChoiceExpression.designer();
    } else {
      final newNotExpression = NotExpression.designer();
      newExpression = newNotExpression;
    }

    widget.updateExpression(newExpression);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(10),
        child: Column(children: <Widget>[
          ListTile(
              title: Row(
            children: [
              DropdownButton<String>(
                value: widget.expression is ValueExpression ? ValueExpression.expressionType : widget.expression.type,
                onChanged: _changeExpressionType,
                items: [NotExpression.expressionType, ValueExpression.expressionType]
                    .map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('${value[0].toUpperCase()}${value.substring(1)}'),
                  );
                }).toList(),
              ),
              Text('Expression')
            ],
          )),
          Padding(padding: const EdgeInsets.all(8), child: _buildExpressionBody())
        ]));
  }

  Widget _buildExpressionBody() {
    final expression = widget.expression;
    if (expression is ValueExpression) {
      return ValueExpressionEditor(
          expression: widget.expression, questions: widget.questions, updateExpression: widget.updateExpression);
    } else if (expression is NotExpression) {
      return NotExpressionEditor(expression: widget.expression, questions: widget.questions);
    } else {
      return Text('To be implemented');
    }
  }
}
