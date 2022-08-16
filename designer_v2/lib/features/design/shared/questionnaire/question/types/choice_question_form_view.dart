import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/action_menu.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

// TODO needs finished concept/design
class ChoiceQuestionFormView extends StatelessWidget {
  const ChoiceQuestionFormView({
    required this.formViewModel,
    Key? key
  }) : super(key: key);

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context) {
    print(formViewModel.answerOptionsArray.valid);
    return Column(
      children: [
        FormTableLayout(
            rows: [
              FormTableRow(
                label: "Text".hardcoded,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelHelpText: "TODO Question text help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.questionTextControl,
                  decoration: InputDecoration(
                    hintText: "Type your question".hardcoded,
                  ),
                ),
              ),
              FormTableRow(
                label: "Type".hardcoded,
                input: ReactiveDropdownField<SurveyQuestionType>(
                  formControl: formViewModel.questionTypeControl,
                  //decoration: const NullHelperDecoration(),
                  items: formViewModel.questionTypeControlOptions.map(
                          (option) => DropdownMenuItem(
                            value: option.value,
                            child: Text(option.label),
                          )).toList(),
                ),
              ),
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
                child: Text("+ Add answer option".hardcoded),
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
              label: "Multiple selection".hardcoded,
              labelHelpText: "TODO Multiple selection help text".hardcoded,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              input: ReactiveSwitch(
                formControl: formViewModel.isMultipleChoiceControl,
              ),
            ),
          ]
        ),
      ],
    );
  }

  List<Widget> _buildRow(
      BuildContext context,
      AbstractControl<String> item,
      int rowIdx,
      Set<MaterialState> states
  ) {
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
          hintText: "Option".hardcoded,
        ),
      ),
    ];
  }
}
