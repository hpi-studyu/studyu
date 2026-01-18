import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/standard_table.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';

class FormListView<T> extends StatelessWidget {
  const FormListView({
    required this.control,
    required this.items,
    required this.onSelectItem,
    required this.getActionsAt,
    this.onNewItem,
    required this.onNewItemLabel,
    required this.rowTitle,
    this.rowPrefix,
    this.rowSuffix,
    this.leadingWidget,
    this.sectionTitle,
    this.sectionDescription,
    this.emptyIcon,
    this.emptyTitle,
    this.emptyDescription,
    this.itemsPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.hideLeadingTrailingWhenEmpty = false,
    this.reorderable = false,
    this.onReorder,
    super.key,
  });

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
  final WidgetBuilderAt<T>? rowPrefix;
  final WidgetBuilderAt<T>? rowSuffix;
  final Widget? leadingWidget;
  final EdgeInsets itemsPadding;
  final bool hideLeadingTrailingWhenEmpty;
  final bool reorderable;
  final void Function(int oldIndex, int newIndex)? onReorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasEmptyWidget =
        emptyIcon != null || emptyTitle != null || emptyDescription != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingWidget != null) leadingWidget!,
        if (sectionTitle != null && !(hasEmptyWidget && items.isEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FormSectionHeader(title: sectionTitle!, divider: false),
          ),
        if (sectionDescription != null && !(hasEmptyWidget && items.isEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(sectionDescription!, style: theme.textTheme.bodyMedium),
          ),
        if (items.isEmpty && hasEmptyWidget)
          EmptyBody(
            icon: emptyIcon,
            title: emptyTitle,
            description: emptyDescription,
            button: _newItemButton(),
          )
        else if (reorderable && items.length > 1)
          ReorderableListView.builder(
            // buildDefaultDragHandles: true,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            onReorder:
                onReorder ??
                (oldIndex, newIndex) {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = items.removeAt(oldIndex);
                  items.insert(newIndex, item);
                  // Optionally, call setState or notify listeners if needed
                },
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                key: ValueKey(item),
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () => onSelectItem(item),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Reorderable handle at the beginning with grab cursor
                        /* MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: ReorderableDragStartListener(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Icon(Icons.drag_handle,
                                  color: Colors.grey[600]),
                            ),
                          ),
                        ), */
                        if (rowPrefix != null) rowPrefix!(context, item, index),
                        Expanded(
                          child: Text(
                            rowTitle(item),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (rowSuffix != null) rowSuffix!(context, item, index),
                        if (getActionsAt(item, index).isNotEmpty)
                          ActionPopUpMenuButton(
                            actions: getActionsAt(item, index),
                          ),
                        const SizedBox(width: 8.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                key: ValueKey(item),
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () => onSelectItem(item),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (rowPrefix != null) rowPrefix!(context, item, index),
                        Expanded(
                          child: Text(
                            rowTitle(item),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (rowSuffix != null) rowSuffix!(context, item, index),
                        if (getActionsAt(item, index).isNotEmpty)
                          ActionPopUpMenuButton(
                            actions: getActionsAt(item, index),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        if (!hideLeadingTrailingWhenEmpty || items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _newItemButton(),
          ),
      ],
    );
  }

  Widget _newItemButton() {
    if (control.disabled || onNewItem == null) {
      return const SizedBox.shrink();
    }
    return PrimaryButton(text: onNewItemLabel, onPressed: onNewItem);
  }
}
