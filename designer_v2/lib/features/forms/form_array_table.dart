import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';

typedef FormArrayTableRowLabelProvider<T> = String Function(T item);
typedef WidgetBuilderAt<T> = Widget Function(
    BuildContext context, T item, int rowIdx);

class FormArrayTable<T> extends StatelessWidget {
  const FormArrayTable({
    required this.control,
    required this.items,
    required this.onSelectItem,
    required this.getActionsAt,
    this.onNewItem,
    required this.onNewItemLabel,
    required this.rowTitle,
    this.rowPrefix,
    this.leadingWidget,
    this.sectionTitle,
    this.sectionTitleDivider = true,
    this.sectionDescription,
    this.emptyIcon,
    this.emptyTitle,
    this.emptyDescription,
    this.itemsSectionPadding =
        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
    Key? key,
  })  : assert(sectionTitle == null || leadingWidget == null,
            "Cannot specify both sectionTitle and leadingWidget"),
        super(key: key);

  final AbstractControl control;

  final List<T> items;
  final OnSelectHandler<T> onSelectItem;
  final ActionsProviderAt<T> getActionsAt;
  final VoidCallback? onNewItem;
  final FormArrayTableRowLabelProvider<T> rowTitle;

  final String onNewItemLabel;
  final String? sectionTitle;
  final String? sectionDescription;

  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptyDescription;

  final bool? sectionTitleDivider;

  final WidgetBuilderAt<T>? rowPrefix;

  final Widget? leadingWidget;

  final EdgeInsets? itemsSectionPadding;

  static final List<StandardTableColumn> columns = [
    const StandardTableColumn(
        label: '', // don't care (showTableHeader=false)
        columnWidth: FlexColumnWidth()),
  ];

  @override
  Widget build(BuildContext context) {
    final hasEmptyWidget =
        emptyIcon != null || emptyTitle != null || emptyDescription != null;

    const leadingWidgetsSpacing = 4.0;

    final Widget leading = Column(
      children: [
        (leadingWidget != null) ? leadingWidget! : const SizedBox.shrink(),
        (sectionTitle != null && leadingWidget != null)
            ? const SizedBox(height: leadingWidgetsSpacing)
            : const SizedBox.shrink(),
        (sectionTitle != null)
            ? FormSectionHeader(title: sectionTitle!, divider: false)
            : const SizedBox.shrink(),
        (sectionTitleDivider == true &&
                (sectionTitle != null || leadingWidget != null))
            ? const Divider()
            : const SizedBox.shrink(),
        (sectionDescription != null &&
                (sectionTitle != null || leadingWidget != null))
            ? const SizedBox(height: leadingWidgetsSpacing)
            : const SizedBox.shrink(),
        (sectionDescription != null)
            ? TextParagraph(text: sectionDescription!)
            : const SizedBox.shrink(),
      ],
    );

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
      tableWrapper: (table) => Padding(
        padding: (items.isNotEmpty && itemsSectionPadding != null)
            ? itemsSectionPadding!
            : EdgeInsets.zero,
        child: table,
      ),
      leadingWidget: leading ?? const SizedBox.shrink(),
      trailingWidget: _newItemButton(),
      emptyWidget: (hasEmptyWidget)
          ? EmptyBody(
              icon: emptyIcon,
              title: emptyTitle,
              description: emptyDescription,
              button: _newItemButton(),
            )
          : null,
    );
  }

  List<Widget> _buildRow(
      BuildContext context, T item, int rowIdx, Set<MaterialState> states) {
    final theme = Theme.of(context);
    final tableTextStyleSecondary = theme.textTheme.bodyText1!;

    return [
      SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            (rowPrefix != null)
                ? rowPrefix!(context, item, rowIdx)
                : const SizedBox.shrink(),
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
    if (control.disabled) {
      return const SizedBox.shrink();
    }
    return PrimaryButton(
      icon: Icons.add,
      text: onNewItemLabel,
      onPressed: onNewItem,
    );
  }
}
