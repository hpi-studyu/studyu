import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/theme.dart';

import '../report_item_form_controller.dart';

class AverageSectionFormView extends ConsumerWidget {
  const AverageSectionFormView({super.key, required this.formViewModel});

  final ReportSectionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: 'Temporal Aggregation',
              labelHelpText: 'temp aggr tooltip',
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              // TODO: extract custom dropdown component with theme + focus fix
              input: Theme(
                data: theme.copyWith(inputDecorationTheme: ThemeConfig.dropdownInputDecorationTheme(theme)),
                child: ReactiveDropdownField<TemporalAggregation>(
                  formControl: formViewModel.averageAggregrationControl,
                  items: TemporalAggregation.values.map(
                        (aggregation) => DropdownMenuItem(
                          value: aggregation,
                          child: Text(aggregation.toString().substring(aggregation.toString().indexOf('.') + 1)),
                        ),
                  ).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        /*DataReferenceEditor<num>(
          reference: formViewModel.buildFormData().section. //widget.section.resultProperty,
          availableTaks: tasks,
          updateReference: (reference) => setState(() => widget.section.resultProperty = reference),
        ),*/
      ],
    );
  }
}
