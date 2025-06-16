import 'package:async/async.dart'; // Add this import for StreamGroup
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/conditional_question_properties.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/theme.dart';

class ConditionalQuestionFormView extends StatefulWidget {
  const ConditionalQuestionFormView(
      {required this.formViewModel, required this.allQuestions, super.key});

  final IConditionalQuestionProperties formViewModel;
  final List<Question> allQuestions;

  @override
  State<ConditionalQuestionFormView> createState() =>
      _ConditionalQuestionFormViewState();
}

class _ConditionalQuestionFormViewState
    extends State<ConditionalQuestionFormView> {
  /*@override
  void initState() {
    super.initState();
    print(
        'Initializing ConditionalQuestionFormView with ${widget.formViewModel.conditionsArray.controls.length} conditions');
    widget.formViewModel.conditionsArray.onChanged((control) {
      print('Conditions changed: ${control.value}');
      for (final condition in widget.formViewModel.conditionsArray.controls) {
        final conditionVm = condition.value;
        if (conditionVm is ConditionRowFormViewModel) {
          conditionVm.valueControl.valueChanges.listen((_) {
            print(
                'Condition value changed: ${conditionVm.valueControl.value} for question ${conditionVm.questionIdControl.value}');
          });
          /*conditionVm.onControlChanged(() {
            print(
                'Condition control changed: ${conditionVm.questionIdControl.value}');
          });*/
        }
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ReactiveFormConsumer(builder: (context, form, _) {
      print(
          'Building ConditionalQuestionFormView with ${widget.formViewModel.conditionsArray.controls.length} conditions');

      // Collect all streams from each condition
      final streams = widget.formViewModel.conditionsArray.controls
          .map((control) => control.value!.form.valueChanges)
          .toList();
      final mergedStream = streams.isNotEmpty
          ? StreamGroup.merge(streams)
          : const Stream<void>.empty();

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
          StreamBuilder(
            stream: mergedStream,
            builder: (context, snapshot) {
              print('Rebuilding live preview due to condition value changes');
              return _buildLivePreview(context);
            },
          ),
        ],
      );
    });
  }

  Widget _buildLogicGroupingControl() {
    return Row(
      children: [
        const Text('Combine conditions with:'),
        const SizedBox(width: 8),
        Expanded(
          child: ReactiveRadioListTile<LogicType>(
            formControl: widget.formViewModel.logicTypeControl,
            value: LogicType.and,
            title: const Text('AND'),
          ),
        ),
        Expanded(
          child: ReactiveRadioListTile<LogicType>(
            formControl: widget.formViewModel.logicTypeControl,
            value: LogicType.or,
            title: const Text('OR'),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionsList() {
    return ReactiveFormArray(
      formArray: widget.formViewModel.conditionsArray,
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
                  context, formArray.controls[index].value!, index),
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
              isExpanded: true,
              items: conditionVm.availableQuestions
                  .map((option) => DropdownMenuItem(
                        value: option.id,
                        child: Text(
                          option.prompt!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'tr.field_question',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              /*onChanged: (value) {
                print("Dropdown question changed");
              },*/
            ),
          ),
          const SizedBox(width: 8),
          // Rebuild comparator when question changes
          ReactiveValueListenableBuilder<String>(
            formControl: conditionVm.questionIdControl,
            builder: (context, _, __) {
              if (conditionVm.selectedQuestion != null) {
                return Expanded(
                  child: ReactiveDropdownField<dynamic>(
                    formControl: conditionVm.comparatorControl,
                    isExpanded: true,
                    items: conditionVm.availableComparators
                        .map((option) => DropdownMenuItem(
                              value: option.value,
                              child: Text(
                                option.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'tr.field_comparator',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
          // Rebuild value when question or comparator changes
          ReactiveValueListenableBuilder<String>(
            formControl: conditionVm.questionIdControl,
            builder: (context, _, __) {
              return ReactiveValueListenableBuilder<dynamic>(
                formControl: conditionVm.comparatorControl,
                builder: (context, _, __) {
                  if (conditionVm.comparatorControl.value != null &&
                      conditionVm.selectedQuestion != null) {
                    return Expanded(
                      flex: 2,
                      child: _buildValueInputField(context, conditionVm),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => widget.formViewModel.removeCondition(index),
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
        return ReactiveDropdownField<dynamic>(
          formControl: conditionVm.valueControl,
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
          isExpanded: true,
          items: conditionVm.availableChoiceValues
              .map((option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(
                      option.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          decoration: const InputDecoration(
            labelText: 'tr.field_value',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );
      case 'scale':
        return ReactiveTextField<dynamic>(
          formControl: conditionVm.valueControl,
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
        return ReactiveTextField<dynamic>(
          formControl: conditionVm.valueControl,
          decoration: const InputDecoration(
            labelText: 'tr.field_value',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddConditionButton() {
    return ElevatedButton.icon(
      onPressed: () =>
          widget.formViewModel.addCondition(allQuestions: widget.allQuestions),
      icon: const Icon(Icons.add),
      label: const Text('tr.button_add_condition'),
    );
  }

  Widget _buildLivePreview(BuildContext context) {
    final List<Expression> currentExpressions = [];
    for (final control in widget.formViewModel.conditionsArray.controls) {
      final expression = control.value?.buildExpression();
      if (expression != null) {
        currentExpressions.add(expression);
      }
    }

    final CompositeExpression tempComposite = CompositeExpression(
      // Use AND as default if logicType is null
      logicType: widget.formViewModel.logicTypeControl.value ?? LogicType.and,
      expressions: currentExpressions,
    );

    return LiveConditionPreview(
      compositeExpression: tempComposite,
      allQuestions: widget.allQuestions,
      currentQuestionId: widget.formViewModel.currentQuestionId,
    );
  }
}

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
        return '${_getQuestionPreviewText(innerExp.target!)} is false';
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
    print('Building LiveConditionPreview with ${compositeExpression.toJson()}');
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
