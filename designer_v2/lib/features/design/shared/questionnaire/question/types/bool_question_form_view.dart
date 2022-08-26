import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_tabs.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/shared_question_views.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

abstract class QuestionTypeFormView extends ConsumerWidget
    implements IQuestionTypeFormWidget {
  const QuestionTypeFormView({Key? key}) : super(key: key);

  @override
  Widget? content(BuildContext context) {
    return null; // override in subclasses to provide the tab's content
  }

  @override
  Widget? customize(BuildContext context) {
    return null; // override in subclasses to provide the tab's content
  }

  @override
  Widget? logic(BuildContext context) {
    return null; // override in subclasses to provide the tab's content
  }
}

class BoolQuestionFormView extends QuestionTypeFormView {
  const BoolQuestionFormView({required this.formViewModel, Key? key})
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
        Opacity(
          opacity: 0.25,
          child: FormSectionHeader(
            title: "Response options",
            helpText:
                "Define the options that participants can answer your question with"
                    .hardcoded,
            divider: false,
          ),
        ),
        const SizedBox(height: 12.0),
        Opacity(
          opacity: 0.4,
          child: StandardTable<AbstractControl<String>>(
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
            buildCellsAt: _buildOptionRow,
            trailingActionsAt: (control, _) => [],
            cellSpacing: 0.0,
            rowSpacing: 1.0,
            showTableHeader: false,
            rowStyle: StandardTableStyle.plain,
            disableRowInteractions: true,
            trailingWidget: null,
            trailingWidgetSpacing: 0,
          ),
        ),
      ],
    );
  }

  // TODO extract this
  List<Widget> _buildOptionRow(
    BuildContext context,
    AbstractControl<String> item,
    int rowIdx,
    Set<MaterialState> states,
  ) {
    final theme = Theme.of(context);
    final formControl = item as FormControl;

    return [
      Icon(
        Icons.radio_button_off_outlined,
        color: theme.dividerTheme.color ?? theme.dividerColor,
        size: 12.0,
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
