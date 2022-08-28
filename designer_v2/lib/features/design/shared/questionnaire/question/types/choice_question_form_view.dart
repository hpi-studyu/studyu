import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/action_menu.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/theme.dart';

class ChoiceQuestionFormView extends ConsumerWidget {
  const ChoiceQuestionFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FormTableLayout(rows: [
          FormTableRow(
            label: "Select multiple".hardcoded,
            labelHelpText: "Allow the participant to select multiple response "
                    "options. \nOtherwise only a single option can be selected."
                .hardcoded,
            input: ReactiveSwitch(
              formControl: formViewModel.isMultipleChoiceControl,
            ),
          ),
        ]),
        const SizedBox(height: 12.0),
        ReactiveFormArray(
          formArray: formViewModel.answerOptionsArray,
          builder: (context, formArray, child) {
            return StandardTable<AbstractControl<String>>(
              items: formViewModel.answerOptionsControls,
              columns: const [
                StandardTableColumn(
                  label: '', // don't care (showTableHeader=false)
                  columnWidth: FixedColumnWidth(32.0),
                ),
                StandardTableColumn(
                    label: '', // don't care (showTableHeader=false)
                    columnWidth: FlexColumnWidth()),
              ],
              onSelectItem: (_) => {}, // no-op
              buildCellsAt: buildChoiceOptionRow,
              trailingActionsAt: (control, _) =>
                  formViewModel.availableActions(control),
              cellSpacing: 0.0,
              rowSpacing: 1.0,
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
                        child: Hyperlink(
                          text: "+ Add option",
                          visitedColor: null,
                          onClick: formViewModel.onNewItem,
                        ),
                      ),
                    )
                  : null,
              trailingWidgetSpacing: 0,
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
  AbstractControl<String> item,
  int rowIdx,
  Set<MaterialState> states,
) {
  final theme = Theme.of(context);
  final formControl = item as FormControl;

  return [
    Center(
      child: Icon(
        Icons.radio_button_off_outlined,
        color: theme.dividerTheme.color ?? theme.dividerColor,
        size: 12.0,
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
