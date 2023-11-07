import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_designer_v2/common_views/action_inline_menu.dart';
import 'package:studyu_designer_v2/common_views/action_menu.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

typedef OnSelectHandler<T> = void Function(T item);

typedef StandardTableRowBuilder = TableRow Function(BuildContext context, List<StandardTableColumn> columns);

typedef StandardTableCellsBuilder<T> = List<Widget> Function(
    BuildContext context, T item, int rowIdx, Set<MaterialState> states);

enum StandardTableStyle { plain, material }

/// Default descriptor for a table column
class StandardTableColumn {
  StandardTableColumn({
    required this.label,
    this.tooltip,
    this.columnWidth = const FlexColumnWidth(),
    this.sortable = false,
  });

  final String label;
  final String? tooltip;
  final TableColumnWidth columnWidth;
  final bool sortable;

  bool? sortAscending;
  Widget? sortableIcon;
}

class StandardTable<T> extends StatefulWidget {
  StandardTable({
    required this.items,
    required List<StandardTableColumn>? columns,
    required this.onSelectItem,
    required this.buildCellsAt,
    this.pinnedPredicates,
    this.sortColumnPredicates,
    this.trailingActionsAt,
    StandardTableColumn? trailingActionsColumn,
    this.trailingActionsMenuType = ActionMenuType.popup,
    this.headerRowBuilder,
    this.dataRowBuilder,
    this.cellSpacing = 10.0,
    this.rowSpacing = 9.0,
    this.minRowHeight = 60.0,
    this.showTableHeader = true,
    this.tableWrapper,
    this.leadingWidget,
    this.trailingWidget,
    this.leadingWidgetSpacing = 12.0,
    this.trailingWidgetSpacing = 8.0,
    this.emptyWidget,
    this.rowStyle = StandardTableStyle.material,
    this.disableRowInteractions = false,
    this.hideLeadingTrailingWhenEmpty = true,
    super.key,
  }) {
    if (trailingActionsColumn == null) {
      this.inputTrailingActionsColumn = StandardTableColumn(
          label: '', columnWidth: const MaxColumnWidth(IntrinsicColumnWidth(), FixedColumnWidth(65)));
    } else {
      this.inputTrailingActionsColumn = trailingActionsColumn;
    }
    // Insert trailing column for actions menu
    if (trailingActionsAt != null) {
      this.inputColumns = [...?columns];
      this.inputColumns.add(this.inputTrailingActionsColumn);
    }
  }

  final List<T> items;
  late final List<StandardTableColumn> inputColumns;
  final OnSelectHandler<T> onSelectItem;
  final ActionsProviderAt<T>? trailingActionsAt;
  final ActionMenuType? trailingActionsMenuType;

  final StandardTableCellsBuilder<T> buildCellsAt;
  final List<int Function(T a, T b)?>? sortColumnPredicates;
  final int Function(T a, T b)? pinnedPredicates;
  final StandardTableRowBuilder? headerRowBuilder;
  final StandardTableRowBuilder? dataRowBuilder;
  late final StandardTableColumn inputTrailingActionsColumn;

  final WidgetDecorator? tableWrapper;

  final double cellSpacing;
  final double rowSpacing;
  final double? minRowHeight;

  final bool showTableHeader;
  final bool hideLeadingTrailingWhenEmpty;

  /// Optional widget rendered above/below the table body
  final Widget? leadingWidget;
  final Widget? trailingWidget;

  final double? leadingWidgetSpacing;
  final double? trailingWidgetSpacing;

  /// Optional widget rendered when there are no rows in the table
  /// If undefined, renders an empty table instead
  final Widget? emptyWidget;

  final StandardTableStyle rowStyle;

  final bool disableRowInteractions;

  @override
  State<StandardTable<T>> createState() => _StandardTableState<T>();
}

class _StandardTableState<T> extends State<StandardTable<T>> {
  /// Cached list of [TableRow]s corresponding to each item in [widget.items]
  final List<TableRow> _cachedRows = [];

  /// Current set of [MaterialState]s for each row in [_cachedRows]
  /// Used to keep track of current hover & pressed status
  final List<Set<MaterialState>> _rowStates = [];

  /// Indices to rebuild [TableRow]s for instead of using the cached version
  final Set<int> _dirtyRowIndices = {};

  /// Static helper row for padding
  late final TableRow paddingRow = _buildPaddingRow();

  List<T>? sortDefaultOrder;

  @override
  void initState() {
    super.initState();
    _initRowStates();
  }

  @override
  void didUpdateWidget(StandardTable<T> oldWidget) {
    _initRowStates();
    _cachedRows.clear();
    _dirtyRowIndices.clear();
    super.didUpdateWidget(oldWidget);
  }

  _initRowStates() {
    _rowStates.clear();
    for (var _ in widget.items) {
      _rowStates.add(<MaterialState>{});
    }
  }

  _onRowStateChanged(int rowIdx, Set<MaterialState> states) {
    setState(() {
      _rowStates[rowIdx] = states;
      // flag row for rebuild to reflect its current set of [MaterialStatus]
      _dirtyRowIndices.add(rowIdx);
    }); // widget is rebuilt after calling [setState] here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Map<int, TableColumnWidth> columnWidths = {};
    for (var idx = 0; idx < widget.inputColumns.length; idx++) {
      columnWidths[idx] = widget.inputColumns[idx].columnWidth;
    }

    final headerRow = _buildHeaderRow();
    final tableHeaderRows = (widget.showTableHeader) ? [headerRow, paddingRow, paddingRow] : [];
    final tableDataRows = _tableRows(theme);

    Widget tableWidget = Table(
        columnWidths: columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [...tableHeaderRows, ...tableDataRows]);
    if (widget.tableWrapper != null) {
      tableWidget = widget.tableWrapper!(tableWidget);
    }

    final isTableVisible = !(tableHeaderRows.isEmpty && tableDataRows.isEmpty);

    if (tableDataRows.isEmpty && widget.emptyWidget != null && widget.hideLeadingTrailingWhenEmpty) {
      return widget.emptyWidget!;
    }

    if (widget.leadingWidget != null || widget.trailingWidget != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.leadingWidget ?? const SizedBox.shrink(),
          (widget.leadingWidget != null && widget.leadingWidgetSpacing != null)
              ? SizedBox(height: widget.leadingWidgetSpacing!)
              : const SizedBox.shrink(),
          (isTableVisible) ? tableWidget : Container(),
          (!isTableVisible && widget.emptyWidget != null && !widget.hideLeadingTrailingWhenEmpty)
              ? widget.emptyWidget!
              : const SizedBox.shrink(),
          (widget.trailingWidget != null && widget.trailingWidgetSpacing != null)
              ? SizedBox(height: widget.trailingWidgetSpacing!)
              : const SizedBox.shrink(),
          widget.trailingWidget ?? const SizedBox.shrink(),
        ],
      );
    }
    return tableWidget;
  }

  void _sortColumn(int columnIndex) {
    if (!(columnIndex >= 0 && columnIndex < widget.inputColumns.length)) return;
    final sortAscending = widget.inputColumns[columnIndex].sortAscending;

    // Save default order to restore later
    if (sortDefaultOrder == null || sortDefaultOrder!.length != widget.items.length) {
      sortDefaultOrder = List.from(widget.items);
    }

    if (sortAscending != null) {
      widget.items.sort((a, b) {
        return _sortLogic(a, b, columnIndex: columnIndex, sortAscending: sortAscending);
      });
      _sortPinnedStudies(widget.items, columnIndex: columnIndex, sortAscending: sortAscending);
    } else {
      widget.items.clear();
      widget.items.addAll(sortDefaultOrder!);
      _sortPinnedStudies(widget.items, columnIndex: columnIndex);
    }
    _cachedRows.clear();
  }

  void _sortPinnedStudies(List<T> items, {required int columnIndex, bool? sortAscending}) {
    // Extract and insert pinned items at the top
    if (widget.pinnedPredicates != null) {
      items.sort((a, b) {
        int ret = widget.pinnedPredicates!(a, b);
        // Fallback to default sorting algorithm
        return ret == 0 ? _sortLogic(a, b, columnIndex: columnIndex, sortAscending: sortAscending) : ret;
      });
    }
  }

  int _sortLogic(T a, T b, {required int columnIndex, required bool? sortAscending, bool? useSortPredicate}) {
    final sortPredicate = widget.sortColumnPredicates;
    if (useSortPredicate != null && useSortPredicate && sortPredicate != null && sortPredicate[columnIndex] != null) {
      final int res;
      if (sortAscending ?? true) {
        res = sortPredicate[columnIndex]!(a, b);
      } else {
        res = sortPredicate[columnIndex]!(b, a);
      }
      if (res == 0) {
        // Fallback to default sorting algorithm
        return _sortLogic(a, b, columnIndex: columnIndex, sortAscending: sortAscending, useSortPredicate: false);
      }
      return res;
    } else if (a is Comparable && b is Comparable) {
      // If sortPredicate is not provided, use default comparison logic
      return sortAscending ?? true ? Comparable.compare(a, b) : Comparable.compare(b, a);
    } else {
      return 0;
    }
  }

  List<TableRow> _tableRows(ThemeData theme) {
    final List<TableRow> rows = [];

    // reuse or rebuild rows if needed
    for (var rowIdx = 0; rowIdx < widget.items.length; rowIdx++) {
      rows.add(_useCachedOrRebuildRow(rowIdx));
    }

    // update cached rows, don't use setState here during the build process
    _cachedRows.clear();
    _cachedRows.addAll(rows);

    // Add padding after each row
    return rows.map((dataRow) => [dataRow, paddingRow]).expand((element) => element).toList();
  }

  TableRow _useCachedOrRebuildRow(rowIdx) {
    if (rowIdx >= _cachedRows.length) {
      // [_cachedRows] is empty when building for the first time
      return _buildDataRow(rowIdx);
    }
    if (_dirtyRowIndices.contains(rowIdx)) {
      final newRow = _buildDataRow(rowIdx);
      _dirtyRowIndices.remove(rowIdx);
      return newRow;
    }
    return _cachedRows[rowIdx]; // use cached row
  }

  TableRow _buildPaddingRow() {
    TableRow rowSpacer =
        TableRow(children: widget.inputColumns.map((_) => SizedBox(height: widget.rowSpacing)).toList());
    return rowSpacer;
  }

  TableRow _buildHeaderRow() {
    final headerRowBuilder = widget.headerRowBuilder ?? _defaultHeader;
    return headerRowBuilder(context, widget.inputColumns);
  }

  TableRow _defaultHeader(BuildContext context, List<StandardTableColumn> columns) {
    final theme = Theme.of(context);

    final List<Widget> headerCells = [];
    for (var i = 0; i < columns.length; i++) {
      final isLeading = i == 0;
      final isTrailing = i == columns.length - 1;
      headerCells.add(MouseEventsRegion(
        builder: (context, state) {
          return Padding(
              padding: EdgeInsets.fromLTRB(
                  (isLeading || isTrailing) ? 2 * widget.cellSpacing : widget.cellSpacing,
                  widget.cellSpacing,
                  (isLeading || isTrailing) ? 2 * widget.cellSpacing : widget.cellSpacing,
                  widget.cellSpacing),
              child: Row(
                children: [
                  Text(
                    columns[i].label,
                    overflow: TextOverflow.visible,
                    maxLines: 1,
                    softWrap: false,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  widget.inputColumns[i].sortable
                      ? widget.inputColumns[i].sortableIcon ?? const SizedBox(width: 17)
                      : const SizedBox.shrink(),
                ],
              ));
        },
        onEnter: (event) => setState(() => sortAction(i, hover: event)),
        onExit: (event) => setState(() => sortAction(i, hover: event)),
        onTap: () => setState(() => sortAction(i)),
      ));
    }
    return TableRow(children: headerCells);
  }

  void sortAction(int i, {PointerEvent? hover}) {
    if (!widget.inputColumns[i].sortable) return;

    final ascendingIcon = Icon(MdiIcons.arrowUp);
    final descendingIcon = Icon(MdiIcons.arrowDown);
    final hoveredIcon = Icon(MdiIcons.arrowUp, color: Colors.grey);

    setState(() {
      // Clicked
      if (hover == null) {
        switch (widget.inputColumns[i].sortAscending) {
          case null:
            // Reset all column sorting
            for (StandardTableColumn c in widget.inputColumns) {
              c.sortAscending = null;
              c.sortableIcon = null;
            }
            widget.inputColumns[i].sortAscending = true;
            widget.inputColumns[i].sortableIcon = ascendingIcon;
            break;
          case true:
            widget.inputColumns[i].sortAscending = false;
            widget.inputColumns[i].sortableIcon = descendingIcon;
            break;
          case false:
            widget.inputColumns[i].sortAscending = null;
            widget.inputColumns[i].sortableIcon = null;
            break;
        }
        _sortColumn(i);
        // No sorting icon is active or hovered
      } else if (widget.inputColumns[i].sortAscending == null) {
        if (hover is PointerEnterEvent) {
          widget.inputColumns[i].sortableIcon = hoveredIcon;
        } else if (hover is PointerExitEvent) {
          widget.inputColumns[i].sortableIcon = null;
        }
      }
    });
  }

  TableRow _buildDataRow(int rowIdx) {
    final item = widget.items[rowIdx];
    final dataRowBuilder = widget.dataRowBuilder ?? _defaultDataRow;
    final rowStates = _rowStates[rowIdx];

    return dataRowBuilder(context, item, rowIdx, rowStates);
  }

  TableRow _defaultDataRow(
    BuildContext context,
    T item,
    int rowIdx,
    Set<MaterialState> states,
  ) {
    final theme = Theme.of(context);
    final rowIsHovered = states.contains(MaterialState.hovered);
    final rowIsPressed = states.contains(MaterialState.pressed);
    final rowColor =
        (widget.rowStyle == StandardTableStyle.material) ? theme.colorScheme.onPrimary : Colors.transparent;

    Widget decorateCellInteractions(Widget child, {disableOnTap = false}) {
      return MouseEventsRegion(
        onTap: (disableOnTap) ? null : (() => widget.onSelectItem(item)),
        onStateChanged: (states) => _onRowStateChanged(rowIdx, states),
        builder: (context, mouseEventState) => child,
      );
    }

    Widget decorateCell(
      Widget child, {
      alignment = Alignment.centerLeft,
      isLeading = false,
      isTrailing = false,
      disableOnTap = false,
    }) {
      final content = Align(
        alignment: alignment,
        child: child,
      );
      final styledCell = Material(
          color: rowColor,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                (isLeading || isTrailing) ? 2 * widget.cellSpacing : widget.cellSpacing,
                widget.cellSpacing,
                (isLeading || isTrailing) ? 2 * widget.cellSpacing : widget.cellSpacing,
                widget.cellSpacing),
            child: (widget.minRowHeight != null)
                ? SizedBox(
                    height: widget.minRowHeight,
                    child: content,
                  )
                : content,
          ));

      return (!widget.disableRowInteractions)
          ? decorateCellInteractions(styledCell, disableOnTap: disableOnTap)
          : styledCell;
    }

    Widget applyColumnConfiguration(Widget cellWidget, StandardTableColumn column) {
      if (column.tooltip != null) {
        cellWidget = Tooltip(
          message: column.tooltip!,
          child: cellWidget,
        );
      }

      return cellWidget;
    }

    final List<Widget> rawCells = widget.buildCellsAt(context, item, rowIdx, states);

    if (widget.trailingActionsAt != null) {
      // Insert additional table cell to hold actions menu
      final rowActions = widget.trailingActionsAt!(item, rowIdx);
      rawCells.add(_buildActionMenu(context, rowActions));
    }

    final List<Widget> dataCells = [];
    for (var i = 0; i < rawCells.length; i++) {
      final isLeading = i == 0;
      final isTrailing = i == rawCells.length - 1;
      //final disableOnTap = (widget.trailingActionsAt != null && isTrailing)
      //    ? true : false;
      final cellColumnConfig = widget.inputColumns[i];

      Widget cell = rawCells[i];
      cell = decorateCell(
        cell,
        isLeading: isLeading,
        isTrailing: isTrailing,
        disableOnTap: false,
      );
      cell = applyColumnConfiguration(cell, cellColumnConfig);
      dataCells.add(cell);
    }

    return (widget.rowStyle == StandardTableStyle.material)
        ? TableRow(
            key: ObjectKey(item),
            children: dataCells,
            decoration: BoxDecoration(
              border: Border.all(
                color: (rowIsPressed)
                    ? theme.colorScheme.primary.withOpacity(0.7)
                    : theme.colorScheme.primaryContainer.withOpacity(0.9),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                    color: (rowIsPressed)
                        ? theme.colorScheme.primary.withOpacity(0.15)
                        : ((rowIsHovered)
                            ? theme.colorScheme.onSurface.withOpacity(0.2)
                            : theme.colorScheme.onSurface.withOpacity(0.1)),
                    spreadRadius: 0,
                    blurRadius: (rowIsHovered) ? 3 : 2,
                    offset: (rowIsHovered) ? const Offset(1, 1) : const Offset(0, 1))
              ],
              color: theme.colorScheme.onPrimary,
            ),
          )
        : TableRow(
            key: ObjectKey(item),
            children: dataCells,
            decoration: null,
          );
  }

  Widget _buildActionMenu(BuildContext context, List<ModelAction> actions) {
    final Widget actionMenuWidget;

    if (widget.trailingActionsMenuType == ActionMenuType.inline) {
      actionMenuWidget = ActionMenuInline(
        actions: actions,
      );
    } else {
      final theme = Theme.of(context);
      actionMenuWidget = ActionPopUpMenuButton(
        actions: actions,
        orientation: Axis.horizontal,
        triggerIconColor: ThemeConfig.bodyTextMuted(theme).color?.faded(0.6),
        triggerIconColorHover: theme.colorScheme.primary,
        disableSplashEffect: true,
        position: PopupMenuPosition.over,
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: actionMenuWidget,
    );
  }
}
