import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class BoolQuestionFormView extends ConsumerWidget {
  const BoolQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Opacity(
          opacity: 0.5,
          child: StandardTable<String>(
            items: BoolQuestionFormData.kResponseOptions.keys.toList(),
            columns: [
              StandardTableColumn(
                label: '', // don't care (showTableHeader=false)
                columnWidth: const FixedColumnWidth(32.0),
              ),
              StandardTableColumn(
                label: '', // don't care (showTableHeader=false)),
              ),
            ],
            onSelectItem: (_) => {}, // no-op
            buildCellsAt: (context, option, _, _) =>
                _buildBoolOptionRow(context, option),
            trailingActionsAt: (option, _) => [],
            cellSpacing: 0.0,
            rowSpacing: 8.0,
            minRowHeight: null,
            showTableHeader: false,
            rowStyle: StandardTableStyle.plain,
            disableRowInteractions: true,
            trailingWidgetSpacing: 0,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBoolOptionRow(BuildContext context, String option) {
    final theme = Theme.of(context);
    return [
      Center(
        child: Icon(
          Icons.radio_button_off_outlined,
          color: theme.dividerTheme.color ?? theme.dividerColor,
          size: 12.0,
        ),
      ),
      IgnorePointer(
        child: TextFormField(
          initialValue: option,
          enabled: false,
          readOnly: true,
          decoration: InputDecoration(
            hintText: tr.form_array_response_options_choice_hint,
          ),
        ),
      ),
    ];
  }
}
