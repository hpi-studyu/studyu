import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/action_inline_menu.dart';
import 'package:studyu_designer_v2/common_views/action_menu.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class ChoiceQuestionFormView extends ConsumerWidget {
  const ChoiceQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: tr.form_field_response_choice_multiple,
              labelHelpText: tr.form_field_response_choice_multiple_tooltip,
              input: ReactiveSwitch(
                formControl: formViewModel.isMultipleChoiceControl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        ReactiveFormArray(
          formArray: formViewModel.answerOptionsArray,
          builder: (context, formArray, child) {
            Widget listWidget;

            if (formViewModel.isReadonly) {
              listWidget = StandardTable<AbstractControl>(
                items: formViewModel.answerOptionsControls,
                columns: [
                  StandardTableColumn(
                    label: '', // don't care (showTableHeader=false)
                    columnWidth: const FixedColumnWidth(32.0),
                  ),
                  StandardTableColumn(
                    label: '', // don't care (showTableHeader=false),),
                  ),
                ],
                onSelectItem: (_) => {},
                // no-op
                buildCellsAt: (context, control, _, __) =>
                    buildChoiceOptionRow(context, control),
                trailingActionsAt: (control, _) =>
                    formViewModel.availableActions(control),
                cellSpacing: 0.0,
                rowSpacing: 8.0,
                minRowHeight: null,
                showTableHeader: false,
                rowStyle: StandardTableStyle.plain,
                trailingActionsMenuType: ActionMenuType.inline,
                disableRowInteractions: true,
                trailingWidget: (formViewModel.isAddOptionButtonVisible &&
                        !formViewModel.isReadonly)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Opacity(
                          opacity: ThemeConfig.kMuteFadeFactor,
                          child: TextButton.icon(
                            onPressed: formViewModel.onNewItem,
                            icon: const Icon(Icons.add),
                            label:
                                Text(tr.form_array_response_options_choice_new),
                          ),
                        ),
                      )
                    : null,
                trailingWidgetSpacing: 0,
              );
            } else {
              listWidget = ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: formViewModel.answerOptionsControls.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }

                  final item =
                      formViewModel.answerOptionsArray.removeAt(oldIndex);
                  formViewModel.answerOptionsArray.insert(newIndex, item);

                  formViewModel.save();
                },
                itemBuilder: (context, index) {
                  final control = formViewModel.answerOptionsControls[index];
                  final actions = formViewModel.availableActions(control);

                  final key = ValueKey(control);

                  final choiceOptionRowWidgets =
                      buildChoiceOptionRow(context, control);

                  return Card(
                    key: key,
                    color: Colors.transparent,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                              index: index, child: const SizedBox.shrink()),
                          const SizedBox(width: 4.0),
                          choiceOptionRowWidgets[0],
                          const SizedBox(width: 8.0),
                          Expanded(child: choiceOptionRowWidgets[1]),
                          if (actions.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ActionMenuInline(actions: actions),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            Widget? addOptionButtonWidget;
            if (formViewModel.isAddOptionButtonVisible &&
                !formViewModel.isReadonly) {
              addOptionButtonWidget = Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Opacity(
                  opacity: ThemeConfig.kMuteFadeFactor,
                  child: TextButton.icon(
                    onPressed: formViewModel.onNewItem,
                    icon: const Icon(Icons.add),
                    label: Text(tr.form_array_response_options_choice_new),
                  ),
                ),
              );
            }

            return Column(
              children: [
                listWidget,
                if (addOptionButtonWidget != null) addOptionButtonWidget,
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Helper to build a single row in the table of bullet-style response options
List<Widget> buildChoiceOptionRow(
  BuildContext context,
  AbstractControl formControl,
) {
  final theme = Theme.of(context);

  return [
    Center(
      child: Icon(
        Icons.radio_button_off_outlined,
        color: theme.dividerTheme.color ?? theme.dividerColor,
        size: 12.0,
      ),
    ),
    ReactiveTextField(
      formControl: formControl as FormControl<dynamic>,
      decoration: InputDecoration(
        hintText: tr.form_array_response_options_choice_hint,
      ),
    ),
  ];
}
