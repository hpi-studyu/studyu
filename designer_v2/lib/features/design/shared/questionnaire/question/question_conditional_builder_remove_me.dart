// Simplified example - actual implementation will be more complex with state management

import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

class ConditionBuilder extends StatefulWidget {
  final String currentQuestionId; // The question this condition applies to
  final List<Question>
      allPreviousQuestions; // List of all questions before this one
  final QuestionConditional? initialCondition; // Existing condition to edit

  const ConditionBuilder({
    super.key,
    required this.currentQuestionId,
    required this.allPreviousQuestions,
    this.initialCondition,
  });

  @override
  State<ConditionBuilder> createState() => _ConditionBuilderState();
}

class _ConditionBuilderState extends State<ConditionBuilder> {
  late CompositeExpression _compositeCondition;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data or a new empty CompositeExpression
    _compositeCondition = widget.initialCondition?.condition ??
        CompositeExpression(logicType: LogicType.and, expressions: []);
  }

  void _addCondition() {
    setState(() {
      // Add a default empty condition (e.g., first available question, default comparator, null value)
      // This will need careful initialization to avoid errors.
      // For example, a BooleanExpression with a default 'target' and 'value'.
      _compositeCondition.expressions.add(BooleanExpression());
    });
  }

  void _removeCondition(int index) {
    setState(() {
      _compositeCondition.expressions.removeAt(index);
    });
  }

  // This method would be called by SingleConditionRow to update an individual expression
  void _updateExpression(int index, Expression newExpression) {
    setState(() {
      _compositeCondition.expressions[index] = newExpression;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logical Grouping Toggle
        Row(
          children: [
            const Text('Combine conditions with:'),
            Radio<LogicType>(
              value: LogicType.and,
              groupValue: _compositeCondition.logicType,
              onChanged: (value) =>
                  setState(() => _compositeCondition.logicType = value!),
            ),
            const Text('AND'),
            Radio<LogicType>(
              value: LogicType.or,
              groupValue: _compositeCondition.logicType,
              onChanged: (value) =>
                  setState(() => _compositeCondition.logicType = value!),
            ),
            const Text('OR'),
          ],
        ),
        const Divider(),
        // List of individual conditions
        if (_compositeCondition.expressions.isEmpty)
          const Text(
              'No conditions added yet. Click "Add Condition" to start.'),
        for (int i = 0; i < _compositeCondition.expressions.length; i++)
          SingleConditionRow(
            key: ValueKey(_compositeCondition
                .expressions[i]), // Use ValueKey for list reordering
            expression: _compositeCondition.expressions[i],
            allPreviousQuestions: widget.allPreviousQuestions,
            onChanged: (updatedExpression) =>
                _updateExpression(i, updatedExpression),
            onRemove: () => _removeCondition(i),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _addCondition,
          icon: const Icon(Icons.add),
          label: const Text('Add Condition'),
        ),
        const Divider(),
        // Live Preview (will be its own widget or function)
        //LiveConditionPreview(compositeExpression: _compositeCondition),
        // A button to save the _compositeCondition to your Question object
        ElevatedButton(
          onPressed: () {
            // Here you'd save _compositeCondition to the visibility_condition field
            // of the current question. You might pass _compositeCondition up via a callback.
            print('Saving condition: ${_compositeCondition.toJson()}');
            // Navigator.pop(context, QuestionConditional(condition: _compositeCondition));
          },
          child: const Text('Save Condition'),
        ),
      ],
    );
  }
}

// SingleConditionRow widget (conceptual)
class SingleConditionRow extends StatefulWidget {
  final Expression expression; // The individual expression to display/edit
  final List<Question> allPreviousQuestions;
  final ValueChanged<Expression> onChanged;
  final VoidCallback onRemove;

  const SingleConditionRow({
    super.key,
    required this.expression,
    required this.allPreviousQuestions,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<SingleConditionRow> createState() => _SingleConditionRowState();
}

class _SingleConditionRowState extends State<SingleConditionRow> {
  // State for selected question, comparator, and value
  // ... build UI using DropdownButton, TextField etc.
  // Call widget.onChanged whenever the expression changes
  // Call widget.onRemove when delete button is pressed
  @override
  Widget build(BuildContext context) {
    // This is where you build the three dropdowns/inputs based on widget.expression
    // and widget.allPreviousQuestions. This will be the most complex part of the UI.
    return Row(
      children: [
        // Question Selector (Dropdown of previous questions)
        // Comparator Selector (Dropdown, options depend on selected question type)
        // Value Field (TextField/Dropdown, type depends on selected question type)
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: widget.onRemove,
        ),
      ],
    );
  }
}
