import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/action_menu.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/bool_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/shared_question_views.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

// TODO needs finished concept/design
// TODO disabled read-only states
class ChoiceQuestionFormView extends QuestionTypeFormView {
  const ChoiceQuestionFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return content(context);
  }

  @override
  Widget content(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(
          rowLayout: FormTableRowLayout.vertical,
          rows: [
            buildQuestionTextControlRow(formViewModel: formViewModel),
          ],
        ),
        const SizedBox(height: 18.0),
        FormSectionHeader(
          title: "Response options",
          helpText:
              "Define the options that participants can answer your question with"
                  .hardcoded,
          divider: false,
        ),
        const SizedBox(height: 12.0),
        ReactiveFormArray(
          formArray: formViewModel.answerOptionsArray,
          builder: (context, formArray, child) {
            return StandardTable<AbstractControl<String>>(
              items: formViewModel.answerOptionsControls,
              columns: const [
                StandardTableColumn(
                  label: '', // don't care (showTableHeader=false)
                  columnWidth: FixedColumnWidth(48.0),
                ),
                StandardTableColumn(
                    label: '', // don't care (showTableHeader=false)
                    columnWidth: FlexColumnWidth()),
              ],
              onSelectItem: (_) => {}, // no-op
              buildCellsAt: _buildRow,
              trailingActionsAt: (control, _) =>
                  formViewModel.availableActions(control),
              cellSpacing: 0.0,
              rowSpacing: 1.0,
              showTableHeader: false,
              rowStyle: StandardTableStyle.plain,
              trailingActionsMenuType: ActionMenuType.inline,
              disableRowInteractions: true,
              trailingWidget: (formViewModel.isAddOptionButtonVisible)
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
                child: TextButton.icon(
                  onPressed: formViewModel.onNewItem,
                  icon: const Icon(Icons.add_rounded),
                  label: Text("Add option".hardcoded),
                )
              )
                  : null,
              trailingWidgetSpacing: 0,
            );
          },
        ),
        const SizedBox(height: 12.0),
        FormTableLayout(
            rows: [
              FormTableRow(
                label: "Multiple selection".hardcoded,
                labelHelpText: "Allow participants to select multiple response options".hardcoded,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                input: ReactiveSwitch(
                  formControl: formViewModel.isMultipleChoiceControl,
                ),
              ),
            ]
        ),
      ],
    );

    /*
    return Column(
      children: [
        FormTableLayout(
            rows: [
              FormTableRow(
                control: formViewModel.questionTextControl,
                label: tr.text,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelHelpText: tr.text_help_text,
                input: ReactiveTextField(
                  formControl: formViewModel.questionTextControl,
                  decoration: InputDecoration(
                    hintText: tr.type_your_question,
                  ),
                ),
              ),
              // removed tr.type .hardcoded
            ]
        ),
        const SizedBox(height: 8.0),
        ReactiveFormArray(
          formArray: formViewModel.answerOptionsArray,
          builder: (context, formArray, child) {
            return StandardTable<AbstractControl<String>>(
              items: formViewModel.answerOptionsControls,
              columns: [
                // TODO: clean this up
                const StandardTableColumn(
                  label: '', // don't care (showTableHeader=false)
                  columnWidth: FixedColumnWidth(48.0),
                ),
                const StandardTableColumn(
                    label: '', // don't care (showTableHeader=false)
                    columnWidth: FlexColumnWidth()
                ),
              ],
              onSelectItem: (_) => {}, // no-op
              buildCellsAt: _buildRow,
              trailingActionsAt: (control, _) => formViewModel.availableActions(control),
              cellSpacing: 0.0,
              rowSpacing: 2.0,
              showTableHeader: false,
              rowStyle: StandardTableStyle.plain,
              trailingActionsMenuType: ActionMenuType.inline,
              disableRowInteractions: true,
              trailingWidget: TextButton(
                onPressed: formViewModel.onNewItem,
                child: Text(tr.add_answer_option),
              ),
              trailingWidgetSpacing: 0,
            );
          },
        ),
        const SizedBox(height: 4.0),
        const Divider(),
        const SizedBox(height: 4.0),
        FormTableLayout(
          rows: [
            FormTableRow(
              label: tr.multiple_selection,
              labelHelpText: tr.multiple_selection_help_text,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              input: ReactiveSwitch(
                formControl: formViewModel.isMultipleChoiceControl,
              ),
            ),
          ]
        ),
      ],
    );

     */
  }

  List<Widget> _buildRow(BuildContext context, AbstractControl<String> item,
      int rowIdx, Set<MaterialState> states) {
    final theme = Theme.of(context);
    final formControl = item as FormControl;

    return [
      Center(
        child: Icon(
          Icons.radio_button_off_outlined,
          color: theme.dividerTheme.color ?? theme.dividerColor,
          size: 14.0,
        ),
      ),
      ReactiveTextField(
        formControl: formControl,
        decoration: InputDecoration(
          hintText: tr.option,
        ),
      ),
    ];
  }
}
