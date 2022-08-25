import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

// TODO simplify table further (where each column definition has a cell builder (standard text or custom widget))
class MeasurementsTable extends StatelessWidget {
  const MeasurementsTable({
    required this.items,
    required this.onSelectItem,
    required this.getActionsAt,
    required this.onNewItem,
    Key? key
  }) : super(key: key);

  final List<MeasurementSurveyFormData> items;
  final OnSelectHandler<MeasurementSurveyFormData> onSelectItem;
  final ActionsProviderAt<MeasurementSurveyFormData> getActionsAt;
  final VoidCallback onNewItem;

  static final List<StandardTableColumn> columns = [
    StandardTableColumn(
        label: tr.title,
        columnWidth: const FlexColumnWidth()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StandardTable<MeasurementSurveyFormData>(
      items: items,
      columns: columns,
      onSelectItem: onSelectItem,
      buildCellsAt: _buildRow,
      trailingActionsAt: getActionsAt,
      cellSpacing: 10.0,
      rowSpacing: 5.0,
      minRowHeight: 40.0,
      showTableHeader: false,
      leadingWidget: SelectableText(tr.surveys,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(
              fontWeight: FontWeight.bold)),
      trailingWidget: _newItemButton(),
      emptyWidget: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: EmptyBody(
          icon: Icons.content_paste_off_rounded,
          title: tr.no_surveys_defined,
          description: tr.no_surveys_defined_help_text,
          button: _newItemButton()
        ),
      ),
    );
  }

  List<Widget> _buildRow(
      BuildContext context,
      MeasurementSurveyFormData item,
      int rowIdx,
      Set<MaterialState> states
  ) {
    final theme = Theme.of(context);
    final tableTextStyleSecondary = theme.textTheme.bodyText1!.copyWith(
        color: theme.colorScheme.secondary);

    return [
      SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              item.title,
              style: tableTextStyleSecondary.copyWith(
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _newItemButton() {
    return PrimaryButton(
      icon: Icons.add,
      text: tr.add_survey,
      onPressed: onNewItem,
    );
  }
}
