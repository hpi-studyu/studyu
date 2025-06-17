import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/conditional_question_properties.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class ConditionalQuestionFormView extends FormConsumerWidget {
  ConditionalQuestionFormView(
      {required this.formViewModel, required this.allQuestions, super.key}) {
    ConditionRowFormViewModel.availableQuestions = availableQuestions;
  }

  final IConditionalQuestionProperties formViewModel;
  final List<Question> allQuestions;

  List<Question> get availableQuestions {
    final currentIndex =
        allQuestions.indexWhere((q) => q.id == formViewModel.currentQuestionId);
    if (currentIndex == -1) return allQuestions;
    return allQuestions.take(currentIndex).toList();
  }

  @override
  Widget build(BuildContext context, FormGroup form) {
    final theme = Theme.of(context);
    return ReactiveFormConsumer(builder: (context, form, _) {
      // print('Building ConditionalQuestionFormView with ${formViewModel.conditionsArray.controls.length} conditions');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextParagraph(
            text: tr.form_array_question_visibility_logic_description,
            style: ThemeConfig.bodyTextMuted(theme),
          ),
          const SizedBox(height: 16.0),
          FormLabel(
            labelText: tr.form_array_question_visibility_logic_title,
            labelTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            helpText: tr.form_array_question_visibility_logic_tooltip,
          ),
          const SizedBox(height: 12.0),
          _buildLogicGroupingControl(theme),
          const SizedBox(height: 12.0),
          _buildConditionsList(),
          const SizedBox(height: 16.0),
          _buildAddConditionButton(),
          const Divider(height: 32.0),
          StreamBuilder(
            stream: formViewModel.conditionsValueChanges,
            builder: (context, snapshot) {
              // print('Rebuilding live preview due to condition value changes');
              return _buildLivePreview(context);
            },
          ),
        ],
      );
    });
  }

  Widget _buildLogicGroupingControl(ThemeData theme) {
    return Row(
      children: [
        Text(tr.form_array_question_visibility_logic_grouping_title,
            style: ThemeConfig.bodyTextMuted(theme)),
        const SizedBox(width: 8),
        Expanded(
          child: ReactiveRadioListTile<LogicType>(
            formControl: formViewModel.logicTypeControl,
            value: LogicType.and,
            title: Text(
                tr.form_array_question_visibility_logic_grouping_and_title),
          ),
        ),
        Expanded(
          child: ReactiveRadioListTile<LogicType>(
            formControl: formViewModel.logicTypeControl,
            value: LogicType.or,
            title:
                Text(tr.form_array_question_visibility_logic_grouping_or_title),
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
              text: tr.from_array_question_visibility_logic_no_conditions,
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
            child: Tooltip(
              message: conditionVm.selectedQuestion?.prompt ?? '',
              child: ReactiveDropdownField<String>(
                formControl: conditionVm.questionIdControl,
                isExpanded: true,
                items: availableQuestions
                    .asMap()
                    .map((index, option) => MapEntry(
                          index,
                          DropdownMenuItem(
                            value: option.id,
                            child: Row(
                              children: [
                                Icon(
                                  SurveyQuestionType.of(option).icon,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${index + 1}.',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    option.prompt!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .values
                    .toList(),
                decoration: InputDecoration(
                  labelText:
                      tr.form_array_question_visibility_logic_question_title,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
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
                    decoration: InputDecoration(
                      labelText: tr
                          .form_array_question_visibility_logic_comparator_title,
                      border: const OutlineInputBorder(),
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
            onPressed: () => formViewModel.removeCondition(index),
            tooltip: tr.action_delete,
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
          items: [
            DropdownMenuItem(
                value: true,
                child: Text(tr.form_array_question_visibility_logic_true)),
            DropdownMenuItem(
                value: false,
                child: Text(tr.form_array_question_visibility_logic_false)),
          ],
          decoration: InputDecoration(
            labelText: tr.form_array_question_visibility_logic_value_title,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );
      case 'choice':
        return Tooltip(
          message: conditionVm.availableChoiceValues
              .firstWhere(
                  (option) => option.value == conditionVm.valueControl.value)
              .label,
          child: ReactiveDropdownField<dynamic>(
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
            decoration: InputDecoration(
              labelText: tr.form_array_question_visibility_logic_value_title,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
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
            ValidationMessage.number: (error) => tr.validation_number_required,
          },
          decoration: InputDecoration(
            labelText: tr.form_array_question_visibility_logic_value_title,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );
      case 'freeText':
        return ReactiveTextField<dynamic>(
          formControl: conditionVm.valueControl,
          decoration: InputDecoration(
            labelText: tr.form_array_question_visibility_logic_value_title,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddConditionButton() {
    return Tooltip(
      message: availableQuestions.isEmpty
          ? tr.form_array_question_visibility_logic_add_condition_disabled_tooltip
          : '',
      child: ElevatedButton.icon(
        onPressed: availableQuestions.isEmpty
            ? null
            : () => formViewModel.addCondition(),
        icon: const Icon(Icons.add),
        label:
            Text(tr.form_array_question_visibility_logic_add_condition_button),
      ),
    );
  }

  Widget _buildLivePreview(BuildContext context) {
    return LiveConditionPreview(
      compositeExpression: formViewModel.compositeExpression,
      allQuestions: allQuestions,
      currentQuestionId: formViewModel.currentQuestionId,
    );
  }
}

class LiveConditionPreview extends StatelessWidget {
  final CompositeExpression? compositeExpression;
  final List<Question> allQuestions;
  final String currentQuestionId;

  const LiveConditionPreview({
    super.key,
    required this.compositeExpression,
    required this.allQuestions,
    required this.currentQuestionId,
  });

  String _getQuestionPreviewText(String questionId) {
    /*if (questionId == currentQuestionId) {
      // Use the specific question text from the ViewModel for clarity
      return tr.form_array_question_visibility_logic_this_question;
    }*/
    final question = allQuestions.firstWhereOrNull((q) => q.id == questionId);
    return question != null ? 'Q[${question.prompt}]' : 'Q[$questionId]';
  }

  String _formatExpressionForPreview(Expression expression) {
    if (expression is BooleanExpression) {
      return '${_getQuestionPreviewText(expression.target!)} ${tr.form_array_question_visibility_logic_is_true}';
    } else if (expression is NotExpression) {
      final innerExp = expression.expression;
      if (innerExp is BooleanExpression) {
        return '${_getQuestionPreviewText(innerExp.target!)} ${tr.form_array_question_visibility_logic_is_false}';
      } else if (innerExp is ChoiceExpression) {
        // Handle != for choice display
        return '${_getQuestionPreviewText(innerExp.target!)} != [${innerExp.choices.map((c) => _getChoiceText(innerExp.target!, c)).join(', ')}]';
      }
      return '${tr.form_array_question_visibility_logic_not} (${_formatExpressionForPreview(innerExp)})';
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
          comparatorText = tr.form_array_question_visibility_logic_contains;
        case TextComparator.doesNotContain:
          comparatorText =
              tr.form_array_question_visibility_logic_does_not_contain;
      }
      return "${_getQuestionPreviewText(expression.target!)} $comparatorText '${expression.value}'";
    } else if (expression is CompositeExpression) {
      if (expression.expressions.isEmpty) {
        return tr.form_array_question_visibility_logic_always_true;
      }
      final innerParts = expression.expressions
          .map((e) => _formatExpressionForPreview(e))
          .toList();
      final innerJoiner = expression.logicType == LogicType.and
          ? ' ${tr.form_array_question_visibility_logic_grouping_and_title} '
          : ' ${tr.form_array_question_visibility_logic_grouping_or_title} ';
      return '(${innerParts.join(innerJoiner)})';
    }
    return tr.form_array_question_visibility_logic_unknown_expression;
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
    // print('Building LiveConditionPreview with ${compositeExpression.toJson()}');
    String previewText;
    if (compositeExpression == null ||
        compositeExpression!.expressions.isEmpty) {
      previewText =
          '${tr.form_array_question_visibility_logic_preview_description}\n\n(${tr.form_array_question_visibility_logic_always_true})';
    } else {
      final formattedConditions =
          _formatExpressionForPreview(compositeExpression!);
      previewText =
          '${tr.form_array_question_visibility_logic_preview_description}\n\n$formattedConditions';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SelectableText(
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
