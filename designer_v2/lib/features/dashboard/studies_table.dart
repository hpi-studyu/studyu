import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/domain/study.dart';

typedef OnSelectStudyHandler = void Function(Study study);

class StudiesTable extends StatefulWidget {
  const StudiesTable({
    required this.studies,
    required this.onSelectStudy,
    required this.getActionsForStudy,
    this.cellSpacing = 10.0,
    this.rowSpacing = 9.0,
    this.minRowHeight = 50.0,
    Key? key
  }) : super(key: key);

  final List<Study> studies;
  final OnSelectStudyHandler onSelectStudy;
  final ActionsProviderFor<Study> getActionsForStudy;

  final double cellSpacing;
  final double rowSpacing;
  final double minRowHeight;

  @override
  State<StudiesTable> createState() => _StudiesTableState();
}

class _StudiesTableState extends State<StudiesTable> {
  /// Cached list of [TableRow]s corresponding for all [widget.studies]
  final List<TableRow> _cachedRows = [];

  /// Current set of [MaterialState]s for each row in [_cachedRows]
  /// Used to keep track of current hover & pressed status
  final List<Set<MaterialState>> _rowStates = [];

  /// Indices to rebuild [TableRow]s for instead of using the cached version
  final Set<int> _dirtyRowIndices = {};

  /// Static helper row for padding
  late final TableRow paddingRow = _buildPaddingRow();

  @override
  void initState() {
    super.initState();
    _initRowStates();
  }

  @override
  void didUpdateWidget(StudiesTable oldWidget) {
    _initRowStates();
    _cachedRows.clear();
    _dirtyRowIndices.clear();
    super.didUpdateWidget(oldWidget);
  }

  _initRowStates() {
    _rowStates.clear();
    widget.studies.forEach((element) => _rowStates.add(<MaterialState>{}));
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
    print("_StudiesTableState.build");
    final theme = Theme.of(context);

    return Table(
        columnWidths: const {
          0: MaxColumnWidth(FixedColumnWidth(200), FlexColumnWidth(2.5)),
          1: FlexColumnWidth(1.3),
          2: FlexColumnWidth(1.3),
          3: FlexColumnWidth(1.3),
          4: FlexColumnWidth(1.1),
          5: FlexColumnWidth(1.1),
          6: FlexColumnWidth(1.1),
          7: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _buildHeaderRow(context),
          paddingRow,
          paddingRow,
          ..._tableRows(theme)
        ]
    );
  }

  List<TableRow> _tableRows(ThemeData theme) {
    final List<TableRow> rows = [];

    // reuse or rebuild rows if needed
    for (var rowIdx = 0; rowIdx < widget.studies.length; rowIdx++) {
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
      return _buildRow(rowIdx);
    }
    if (_dirtyRowIndices.contains(rowIdx)) {
      final newRow = _buildRow(rowIdx);
      _dirtyRowIndices.remove(rowIdx);
      return newRow;
    }
    return _cachedRows[rowIdx]; // use cached row
  }

  TableRow _buildPaddingRow() {
    TableRow rowSpacer = TableRow(children: [
      SizedBox(height: widget.rowSpacing),
      SizedBox(height: widget.rowSpacing),
      SizedBox(height: widget.rowSpacing),
      SizedBox(height: widget.rowSpacing),
      SizedBox(height: widget.rowSpacing),
      SizedBox(height: widget.rowSpacing),
      SizedBox(height: widget.rowSpacing),
      SizedBox(height: widget.rowSpacing),
    ]);
    return rowSpacer;
  }

  TableRow _buildHeaderRow(BuildContext context) {
    final List<String> columns = [
      AppLocalizations.of(context)!.study_title,
      AppLocalizations.of(context)!.status,
      AppLocalizations.of(context)!.enrollment,
      AppLocalizations.of(context)!.started_at,
      AppLocalizations.of(context)!.enrolled,
      AppLocalizations.of(context)!.active,
      AppLocalizations.of(context)!.completed,
      ""
    ];
    final theme = Theme.of(context);
    return TableRow(
        children: columns.map(
                (fieldName) => Padding(
                padding: EdgeInsets.all(widget.cellSpacing),
                child: SelectableText(fieldName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                    )
                )
            )
        ).toList()
    );
  }

  TableRow _buildRow(int rowIdx) {
    final study = widget.studies[rowIdx];

    final theme = Theme.of(context);
    final tableTextStylePrimary = theme.textTheme.bodyText1;
    final tableTextSecondaryColor = theme.colorScheme.secondary;
    final tableTextStyleSecondary = tableTextStylePrimary!.copyWith(
        color: tableTextSecondaryColor);

    final rowIsHovered = _rowStates[rowIdx].contains(MaterialState.hovered);
    final rowIsPressed = _rowStates[rowIdx].contains(MaterialState.pressed);
    final rowColor = theme.colorScheme.onPrimary;

    Widget buildCell(Widget child, {alignment = Alignment.centerLeft}) {
      Widget innerContent = MouseEventsRegion(
          onTap: () => widget.onSelectStudy(study),
          onStateChanged: (states) => _onRowStateChanged(rowIdx, states),
          builder: (context, mouseEventState) => Material(
              color: rowColor,
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: widget.cellSpacing,
                      horizontal: 1.5*widget.cellSpacing
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

    return TableRow(children: [
      buildCell(Text(
          study.title ?? '[study.title]', style: tableTextStylePrimary
      )),
      buildCell(Text(
          study.status.string, style: tableTextStyleSecondary)),
      buildCell(Text(
          study.participation.value, style: tableTextStyleSecondary)),
      // TODO: resolve missing createdAt
      //wrapRowContents(SelectableText(study.createdAt.toString())),
      buildCell(Text(
          "", style: tableTextStyleSecondary)),
      buildCell(Text(
          study.participantCount.toString(), style: tableTextStyleSecondary)),
      buildCell(Text(
          study.activeSubjectCount.toString(), style: tableTextStyleSecondary)),
      buildCell(Text(
          study.endedCount.toString(), style: tableTextStyleSecondary),),
      buildCell(
        ActionPopUpMenuButton(
          actions: widget.getActionsForStudy(study),
          orientation: Axis.horizontal,
          triggerIconColor: tableTextSecondaryColor.withOpacity(0.8),
          triggerIconColorHover: theme.colorScheme.primary,
          disableSplashEffect: true,
          position: PopupMenuPosition.over,
        ),
        alignment: Alignment.center,
      ),
    ],
      decoration: BoxDecoration(
        border: Border.all(
          color: (rowIsPressed) ? theme.colorScheme.primary.withOpacity(0.7) :
          theme.colorScheme.secondaryContainer.withOpacity(0.1),
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
}
