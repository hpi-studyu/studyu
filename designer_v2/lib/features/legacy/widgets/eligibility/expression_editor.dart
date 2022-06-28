import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import './not_expression_editor.dart';
import './value_expression_editor.dart';

class ExpressionEditor extends StatefulWidget {
  final Expression expression;
  final List<Question> questions;
  final void Function(Expression newExpression) updateExpression;

  const ExpressionEditor({
    required this.expression,
    required this.questions,
    required this.updateExpression,
    Key? key,
  }) : super(key: key);

  @override
  _ExpressionEditorState createState() => _ExpressionEditorState();
}

class _ExpressionEditorState extends State<ExpressionEditor> {
  void _changeExpressionType(String? newType) {
    Expression newExpression;

    if (newType == BooleanExpression.expressionType || newType == ValueExpression.expressionType) {
      newExpression = BooleanExpression();
    } else if (newType is ChoiceQuestion) {
      newExpression = ChoiceExpression.withId();
    } else {
      final newNotExpression = NotExpression.withId();
      newExpression = newNotExpression;
    }

    widget.updateExpression(newExpression);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
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
                Text(AppLocalizations.of(context)!.expression)
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(8), child: _buildExpressionBody())
        ],
      ),
    );
  }

  Widget _buildExpressionBody() {
    final expression = widget.expression;
    if (expression is ValueExpression) {
      return ValueExpressionEditor(
        expression: widget.expression as ValueExpression,
        questions: widget.questions,
        updateExpression: widget.updateExpression,
      );
    } else if (expression is NotExpression) {
      return NotExpressionEditor(expression: widget.expression as NotExpression, questions: widget.questions);
    } else {
      return const Text('To be implemented');
    }
  }
}
