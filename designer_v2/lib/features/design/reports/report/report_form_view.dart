import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/reports/report/report_form_controller.dart';

class ReportItemFormView extends StatelessWidget {
  const ReportItemFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final ReportItemFormViewModel formViewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              FormTableRow(
                  control: formViewModel.titleControl,
                  label: 'ReportItemTitle',
                  labelHelpText: 'ReportItemTooltip',
                  input: Row(
                      children: [
                        Text("Hi"),
                      ]
                  )
              )
            ],
          )
        ]
    );
  }
}