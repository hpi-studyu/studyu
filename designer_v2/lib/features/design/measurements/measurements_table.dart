import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurement_survey_form_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

// TODO simplify table further (where each column definition has a cell builder (standard text or custom widget))
class MeasurementsTable extends StatelessWidget {
  const MeasurementsTable({
    required this.items,
    required this.onSelectItem,
    required this.getActionsAt,
    Key? key
  }) : super(key: key);

  final List<MeasurementSurveyFormData> items;
  final OnSelectHandler<MeasurementSurveyFormData> onSelectItem;
  final ActionsProviderAt<MeasurementSurveyFormData> getActionsAt;

  static final List<StandardTableColumn> columns = [
    StandardTableColumn(
        label: 'Title'.hardcoded,
        columnWidth: const FlexColumnWidth()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    print("MeasurementsTable.build");
    if (items.isEmpty) {
      return EmptyBody(
        title: null,
        description: "TODO empty state".hardcoded,
      );
    }

    return StandardTable<MeasurementSurveyFormData>(
        items: items,
        columns: columns,
        onSelectItem: onSelectItem,
        buildCellsAt: _buildRow,
        popoverActionsAt: getActionsAt,
        cellSpacing: 10.0,
        rowSpacing: 5.0,
        minRowHeight: 40.0,
        showTableHeader: false,
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
}
