import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/conditional_question_properties.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/theme.dart';

class ConditionalQuestionFormView extends FormConsumerWidget {
  const ConditionalQuestionFormView(
      {required this.formViewModel, required this.allQuestions, super.key});

  final IConditionalQuestionProperties formViewModel;
  final List<Question> allQuestions;

  @override
  Widget build(BuildContext context, FormGroup form) {
    final theme = Theme.of(context);

    // Rebuild this widget when the form changes by using ReactiveFormConsumer
    return ReactiveFormConsumer(
      builder: (context, formGroup, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextParagraph(
              text: 'tr.form_array_question_visibility_logic_description',
              style: ThemeConfig.bodyTextMuted(theme),
            ),
            const SizedBox(height: 16.0),
            const FormLabel(
              labelText: 'tr.form_array_question_visibility_logic_title',
              labelTextStyle: TextStyle(fontWeight: FontWeight.bold),
              helpText: 'tr.form_array_question_visibility_logic_tooltip',
            ),
            const SizedBox(height: 12.0),
            _buildLogicGroupingControl(),
            const SizedBox(height: 12.0),
            _buildConditionsList(),
            const SizedBox(height: 16.0),
            _buildAddConditionButton(),
            const Divider(height: 32.0),
            _buildLivePreview(context),
          ],
        );
      },
    );
  }

  Widget _buildLogicGroupingControl() {
    return Row(
      children: [
        const Text('Combine conditions with:'),
        const SizedBox(width: 8),
        Expanded(
          child: ReactiveRadioListTile<LogicType>(
            formControl: formViewModel.logicTypeControl,
            value: LogicType.and,
            title: const Text('AND'),
          ),
        ),
        Expanded(
          child: ReactiveRadioListTile<LogicType>(
            formControl: formViewModel.logicTypeControl,
            value: LogicType.or,
            title: const Text('OR'),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionsList() {
    return ReactiveFormArray(
      formArray: formViewModel.conditionsArray,
      builder: (context, formArray, child) {
        if (formArray.controls.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextParagraph(
              text: "tr.no_conditions_added_yet",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return Column(
          children: List.generate(
            formArray.controls.length,
            (index) => KeyedSubtree(
              key: ValueKey(formArray.controls[index]),
              child: _buildSingleConditionRow(
                  context,
                  formArray.controls[index].value as ConditionRowFormViewModel,
                  index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleConditionRow(
    BuildContext context,
    ConditionRowFormViewModel conditionVm,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ReactiveDropdownField<String>(
              formControl: conditionVm.questionIdControl,
              items: conditionVm.availableQuestions
                  .map((option) => DropdownMenuItem(
                        value: option.id,
                        child: Text(option.prompt!),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'tr.field_question',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (conditionVm.selectedQuestion !=
              null) // Only show comparator if question is selected
            Expanded(
              child: ReactiveDropdownField<dynamic>(
                formControl: conditionVm.comparatorControl,
                items: conditionVm.availableComparators
                    .map((option) => DropdownMenuItem(
                          value: option.value,
                          child: Text(option.label),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'tr.field_comparator',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          const SizedBox(width: 8),
          if (conditionVm.comparatorControl.value != null &&
              conditionVm.selectedQuestion !=
                  null) // Only show value if comparator is selected
            Expanded(
              flex: 2,
              child: _buildValueInputField(context, conditionVm),
            ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => formViewModel.removeCondition(index),
            tooltip: 'tr.delete',
          ),
        ],
      ),
    );
  }

  Widget _buildValueInputField(
    BuildContext context,
    ConditionRowFormViewModel conditionVm,
  ) {
    switch (conditionVm.selectedQuestion!.type) {
      case 'boolean':
        return ReactiveDropdownField<bool>(
          formControl: conditionVm.valueControl as FormControl<bool>,
          items: const [
            DropdownMenuItem(value: true, child: Text('tr.true_value')),
            DropdownMenuItem(value: false, child: Text('tr.false_value')),
          ],
          decoration: const InputDecoration(
            labelText: 'tr.field_value',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );
      case 'choice':
        return ReactiveDropdownField<dynamic>(
          formControl: conditionVm.valueControl,
          items: conditionVm.availableChoiceValues
              .map((option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ))
              .toList(),
          decoration: const InputDecoration(
            labelText: 'tr.field_value',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );
      case 'scale':
        return ReactiveTextField(
          formControl: conditionVm.valueControl as FormControl<num>,
          keyboardType: TextInputType.number,
          inputFormatters: const [
            // Potentially add more robust number input formatter
            // (e.g., allow decimals, handle negative numbers)
          ],
          validationMessages: {
            ValidationMessage.number: (error) =>
                'tr.validation_message_must_be_number',
          },
          decoration: const InputDecoration(
            labelText: 'tr.field_value',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );
      case 'text':
        return ReactiveTextField(
          formControl: conditionVm.valueControl as FormControl<String>,
          decoration: const InputDecoration(
            labelText: 'tr.field_value',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );
      default:
        return const SizedBox
            .shrink(); // Should not happen with proper type handling
    }
  }

  Widget _buildAddConditionButton() {
    return ElevatedButton.icon(
      onPressed: () => formViewModel.addCondition(allQuestions: allQuestions),
      icon: const Icon(Icons.add),
      label: const Text('tr.button_add_condition'),
    );
  }

  Widget _buildLivePreview(BuildContext context) {
    // This is a simplified preview; you'd likely want to lift the logic
    // into the ViewModel and expose a stream or getter for the preview text.
    // For reactive forms, you might listen to form.valueChanges.
    final List<Expression> currentExpressions = [];
    /*
    List.generate(
            formArray.controls.length,
            (index) => KeyedSubtree(
              key: ValueKey(formArray.controls[index]),
              child: _buildSingleConditionRow(
                  context,
                  formArray.controls[index].value as ConditionRowFormViewModel,
                  index),
            ),
          ),
     */
    for (final control in formViewModel.conditionsArray.controls) {
      final conditionVm = control.value as ConditionRowFormViewModel;
      final expression = conditionVm.buildExpression();
      if (expression != null) {
        currentExpressions.add(expression);
      }
    }

    final CompositeExpression tempComposite = CompositeExpression(
      logicType: formViewModel.logicTypeControl.value ?? LogicType.and,
      expressions: currentExpressions,
    );

    // LiveConditionPreview (from previous response) needs to be adapted to use the designer's Question model
    return LiveConditionPreview(
      compositeExpression: tempComposite,
      allQuestions: allQuestions,
      //allQuestions: formViewModel.allQuestions,
      currentQuestionId: formViewModel.currentQuestionId,
    );
  }
}

// --- LiveConditionPreview (adapted for designer_q.Question) ---

class LiveConditionPreview extends StatelessWidget {
  final CompositeExpression compositeExpression;
  final List<Question> allQuestions;
  final String currentQuestionId;

  const LiveConditionPreview({
    super.key,
    required this.compositeExpression,
    required this.allQuestions,
    required this.currentQuestionId,
  });

  String _getQuestionPreviewText(String questionId) {
    if (questionId == currentQuestionId) {
      // Use the specific question text from the ViewModel for clarity
      return 'this question'; // Or formViewModel.currentQuestionTitle
    }
    final question = allQuestions.firstWhereOrNull((q) => q.id == questionId);
    return question != null ? 'Q${question.id}' : 'Q<$questionId>';
  }

  String _formatExpressionForPreview(Expression expression) {
    if (expression is BooleanExpression) {
      return '${_getQuestionPreviewText(expression.target!)} is true';
    } else if (expression is NotExpression) {
      final innerExp = expression.expression;
      if (innerExp is BooleanExpression) {
        return '${_getQuestionPreviewText(innerExp.target!)} is not true';
      } else if (innerExp is ChoiceExpression) {
        // Handle != for choice display
        return '${_getQuestionPreviewText(innerExp.target!)} != [${innerExp.choices.map((c) => _getChoiceText(innerExp.target!, c)).join(', ')}]';
      }
      return 'NOT (${_formatExpressionForPreview(innerExp)})';
    } else if (expression is ChoiceExpression) {
      return '${_getQuestionPreviewText(expression.target!)} = [${expression.choices.map((c) => _getChoiceText(expression.target!, c)).join(', ')}]';
    } else if (expression is NumericExpression) {
      final String comparatorSymbol;
      switch (expression.comparator) {
        case NumericComparator.equal:
          comparatorSymbol = '=';
        case NumericComparator.notEqual:
          comparatorSymbol = '!=';
        case NumericComparator.greaterThan:
          comparatorSymbol = '>';
        case NumericComparator.lessThan:
          comparatorSymbol = '<';
        case NumericComparator.greaterThanOrEqual:
          comparatorSymbol = '>=';
        case NumericComparator.lessThanOrEqual:
          comparatorSymbol = '<=';
      }
      return '${_getQuestionPreviewText(expression.target!)} $comparatorSymbol ${expression.value}';
    } else if (expression is TextExpression) {
      final String comparatorText;
      switch (expression.comparator) {
        case TextComparator.equal:
          comparatorText = '=';
        case TextComparator.notEqual:
          comparatorText = '!=';
        case TextComparator.contains:
          comparatorText = 'contains';
        case TextComparator.doesNotContain:
          comparatorText = 'does not contain';
      }
      return "${_getQuestionPreviewText(expression.target!)} $comparatorText '${expression.value}'";
    } else if (expression is CompositeExpression) {
      if (expression.expressions.isEmpty) {
        return 'always true';
      }
      final innerParts = expression.expressions
          .map((e) => _formatExpressionForPreview(e))
          .toList();
      final innerJoiner =
          expression.logicType == LogicType.and ? ' AND ' : ' OR ';
      return '(${innerParts.join(innerJoiner)})';
    }
    return 'Unknown Expression';
  }

  String _getChoiceText(String questionId, dynamic choiceValue) {
    final question = allQuestions.firstWhereOrNull((q) => q.id == questionId);
    if (question is ChoiceQuestion) {
      final choice =
          question.choices.firstWhereOrNull((c) => c.text == choiceValue);
      return choice?.text ??
          choiceValue.toString(); // Return text or value if not found
    }
    return choiceValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    String previewText;
    if (compositeExpression.expressions.isEmpty) {
      previewText = 'Show this question if: (always true)';
    } else {
      final formattedConditions =
          _formatExpressionForPreview(compositeExpression);
      previewText = 'Show this question if: $formattedConditions';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        previewText,
        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      ),
    );
  }

  // Uncomment and implement the following methods if needed
  /*
  Widget _buildConditionsList() {
    // Implement the logic to display the list of conditions
  }

  Widget _buildAddConditionButton() {
    // Implement the logic to add a new condition
  }

  Widget _buildLivePreview(BuildContext context) {
    // Implement the logic to show a live preview of the conditions
  }
  */
}
