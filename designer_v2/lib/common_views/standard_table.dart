import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

typedef OnSelectHandler<T> = void Function(T item);

typedef StandardTableRowBuilder = TableRow Function(
    BuildContext context, List<StandardTableColumn> columns);

typedef StandardTableCellsBuilder<T> = List<Widget> Function(
    BuildContext context, T item, int rowIdx, Set<MaterialState> states);

/// Default descriptor for a table column
class StandardTableColumn {
  const StandardTableColumn({
    required this.label,
    this.columnWidth = const FlexColumnWidth(),
  });

  final String label;
  final TableColumnWidth columnWidth;
}

class StandardTable<T> extends StatefulWidget {
  StandardTable({
    required this.items,
    required this.columns,
    required this.onSelectItem,
    required this.buildCellsAt,
    this.popoverActionsAt,
    this.popoverActionsColumn = const StandardTableColumn(
        label: '', columnWidth: FixedColumnWidth(65)),
    this.headerRowBuilder,
    this.dataRowBuilder,
    this.cellSpacing = 10.0,
    this.rowSpacing = 9.0,
    this.minRowHeight = 50.0,
    this.showTableHeader = true,
    Key? key
  }) : super(key: key) {
    // Insert trailing column for popover actions menu
    if (popoverActionsAt != null) {
      columns = [...columns]; // don't modify original reference
      columns.add(popoverActionsColumn);
    }
  }

  final List<T> items;
  List<StandardTableColumn> columns;
  final OnSelectHandler<T> onSelectItem;
  final ActionsProviderAt<T>? popoverActionsAt;

  final StandardTableCellsBuilder<T> buildCellsAt;
  final StandardTableRowBuilder? headerRowBuilder;
  final StandardTableRowBuilder? dataRowBuilder;
  final StandardTableColumn popoverActionsColumn;

  final double cellSpacing;
  final double rowSpacing;
  final double minRowHeight;

  final bool showTableHeader;

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

  /// Static table header row
  late final TableRow headerRow = _buildHeaderRow();

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
    widget.items.forEach((element) => _rowStates.add(<MaterialState>{}));
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

    final Map<int,TableColumnWidth> columnWidths = {};
    for (var idx = 0; idx < widget.columns.length; idx++) {
      columnWidths[idx] = widget.columns[idx].columnWidth;
    }

    final tableHeaderRows = (widget.showTableHeader)
        ? [headerRow, paddingRow, paddingRow] : [];

    return Table(
        columnWidths: columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          ...tableHeaderRows,
          ..._tableRows(theme)
        ]
    );
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
    return rows.map((dataRow) => [dataRow, paddingRow])
        .expand((element) => element).toList();
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
    TableRow rowSpacer = TableRow(children:
    widget.columns.map((_) => SizedBox(height: widget.rowSpacing)).toList()
    );
    return rowSpacer;
  }

  TableRow _buildHeaderRow() {
    final headerRowBuilder = widget.headerRowBuilder ?? _defaultHeader;
    return headerRowBuilder(context, widget.columns);
  }

  TableRow _defaultHeader(BuildContext context, List<StandardTableColumn> columns) {
    final theme = Theme.of(context);

    final List<Widget> headerCells = [];
    for (var i = 0; i < columns.length; i++) {
      final isLeadingTrailing = i == 0 || i == columns.length-1;
      headerCells.add(Padding(
          padding: EdgeInsets.fromLTRB(
              (isLeadingTrailing) ? 2*widget.cellSpacing : widget.cellSpacing,
              widget.cellSpacing,
              (isLeadingTrailing) ? 2*widget.cellSpacing : widget.cellSpacing,
              widget.cellSpacing
          ),
          child: SelectableText(columns[i].label,
              style: theme.textTheme.caption!.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              )
          )
      ));
    }

    return TableRow(children: headerCells);
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
    final rowColor = theme.colorScheme.onPrimary;

    Widget decorateCell(Widget child, {
      alignment = Alignment.centerLeft,
      isLeadingTrailing = false
    }) {
      Widget innerContent = MouseEventsRegion(
          onTap: () => widget.onSelectItem(item),
          onStateChanged: (states) => _onRowStateChanged(rowIdx, states),
          builder: (context, mouseEventState) => Material(
              color: rowColor,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      (isLeadingTrailing) ? 2*widget.cellSpacing : widget.cellSpacing,
                      widget.cellSpacing,
                      (isLeadingTrailing) ? 2*widget.cellSpacing : widget.cellSpacing,
                      widget.cellSpacing
                  ),
                  child: SizedBox(
                      height: widget.minRowHeight,
                      child: Align(
                        alignment: alignment,
                        child: child,
                      )
                  )
              )
          )
      );

      return innerContent;
    }

    final List<Widget> rawCells = widget.buildCellsAt(
        context, item, rowIdx, states);

    if (widget.popoverActionsAt != null) {
      // Insert additional table cell to hold popover actions menu
      final rowActions = widget.popoverActionsAt!(item, rowIdx) as List<ModelAction>;
      rawCells.add(_buildPopoverActionsMenu(context, rowActions));
    }

    final List<Widget> dataCells = [];
    for (var i = 0; i < rawCells.length; i++) {
      final isLeadingTrailing = i == 0 || i == rawCells.length-1;
      final cell = decorateCell(rawCells[i], isLeadingTrailing: isLeadingTrailing);
      dataCells.add(cell);
    }

    return TableRow(
      children: dataCells,
      decoration: BoxDecoration(
        border: Border.all(
          color: (rowIsPressed) ? theme.colorScheme.primary.withOpacity(0.7) :
          theme.colorScheme.primaryContainer.withOpacity(0.9),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        boxShadow: [BoxShadow(
            color: (rowIsPressed) ? theme.colorScheme.primary.withOpacity(0.15)
                : ((rowIsHovered) ? theme.colorScheme.onSurface.withOpacity(0.2)
                : theme.colorScheme.onSurface.withOpacity(0.1)),
            spreadRadius: 0,
            blurRadius: (rowIsHovered) ? 3 : 2,
            offset: (rowIsHovered) ? const Offset(1,1) : const Offset(0, 1)
        )],
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildPopoverActionsMenu(BuildContext context, List<ModelAction> actions) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: ActionPopUpMenuButton(
        actions: actions,
        orientation: Axis.horizontal,
        triggerIconColor: theme.colorScheme.secondary.withOpacity(0.8),
        triggerIconColorHover: theme.colorScheme.primary,
        disableSplashEffect: true,
        position: PopupMenuPosition.over,
      ),
    );
  }
}
