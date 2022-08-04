import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/action_menu.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

typedef FormArrayTableRowLabelProvider<T> = String Function(T item);

// TODO refactor to make this part of the standard table definition
class FormArrayTable<T> extends StatelessWidget {
  const FormArrayTable({
    required this.items,
    required this.onSelectItem,
    required this.getActionsAt,
    required this.onNewItem,
    required this.onNewItemLabel,
    required this.sectionTitle,
    required this.rowTitle,
    this.emptyIcon,
    this.emptyTitle,
    this.emptyDescription,
    Key? key
  }) : super(key: key);

  final List<T> items;
  final OnSelectHandler<T> onSelectItem;
  final ActionsProviderAt<T> getActionsAt;
  final VoidCallback onNewItem;
  final FormArrayTableRowLabelProvider<T> rowTitle;

  final String onNewItemLabel;
  final String? sectionTitle;

  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptyDescription;

  static final List<StandardTableColumn> columns = [
    const StandardTableColumn(
        label: '', // don't care (showTableHeader=false)
        columnWidth: FlexColumnWidth()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hasEmptyWidget = emptyIcon != null || emptyTitle != null
        || emptyDescription != null;

    return StandardTable<T>(
      items: items,
      columns: columns,
      onSelectItem: onSelectItem,
      buildCellsAt: _buildRow,
      trailingActionsAt: getActionsAt,
      cellSpacing: 10.0,
      rowSpacing: 5.0,
      minRowHeight: 40.0,
      showTableHeader: false,
      leadingWidget: FormTableLayout(
        rows: [
          FormTableRow(
              label: sectionTitle!,
              input: Container(),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold)
          )
        ]
      ),
      trailingWidget: _newItemButton(),
      emptyWidget: (hasEmptyWidget)
          ? Padding(
              padding: const EdgeInsets.only(top: 24),
              child: EmptyBody(
                icon: emptyIcon,
                title: emptyTitle,
                description: emptyDescription,
                button: _newItemButton()
              ),
          ) : null,
    );
  }

  List<Widget> _buildRow(
      BuildContext context,
      T item,
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
              rowTitle(item),
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
      text: onNewItemLabel,
      onPressed: onNewItem,
    );
  }
}
