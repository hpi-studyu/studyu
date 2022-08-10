import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

/// Factory to construct an [InputDecoration] with an empty helper text
///
/// This prevents the height of the widget it is applied to from changing,
/// otherwise [TextField] will grow in height when displaying an error text.
class NullHelperDecoration extends InputDecoration {
  const NullHelperDecoration() : super(helperText: "");
}

class FormTableRow {
  final String label;
  final TextStyle? labelStyle;
  final String? labelHelpText;
  final Widget input;

  FormTableRow({
    required this.label,
    required this.input,
    this.labelStyle,
    this.labelHelpText,
  });
}

/// Renders a list of [FormTableRow]s in a two-column tabular layout
class FormTableLayout extends StatelessWidget {
  const FormTableLayout({
    required this.rows,
    this.columnWidths = const {
      0: FixedColumnWidth(160.0),
      1: FlexColumnWidth(),
    },
    this.rowDivider,
    Key? key
  }) : super(key: key);

  final List<FormTableRow> rows;
  final Map<int,TableColumnWidth> columnWidths;
  final Widget? rowDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<TableRow> tableRows = [];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final isTrailing = i == rows.length-1;
      final bottomSpacing = (!isTrailing) ? 10.0 : 0.0;

      final tableRow = TableRow(
        children: [
          Container(
            padding: EdgeInsets.only(top: 14.0, bottom: bottomSpacing),
            child: Row(
              children: [
                Text(
                  row.label,
                  style: theme.textTheme.caption!.merge(row.labelStyle),
                ),
                (row.labelHelpText != null)
                    ? const SizedBox(width: 8.0) : const SizedBox.shrink(),
                (row.labelHelpText != null)
                    ? Tooltip(
                    message: row.labelHelpText,
                    child: MouseEventsRegion(
                      builder: (context, states) {
                        final iconColor = theme.iconTheme.color?.withOpacity(
                            (states.contains(MaterialState.hovered)) ? 0.5 : 0.3)
                            ?? theme.colorScheme.onSurface.withOpacity(0.3);
                        return Icon(
                          Icons.help_outline_rounded,
                          size: theme.textTheme.caption!.fontSize! + 2.0,
                          color: iconColor,
                        );
                      },
                    ),
                ) : const SizedBox.shrink(),
              ]
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: bottomSpacing),
            child: Align(
              alignment: Alignment.topLeft,
              child: row.input,
            ),
          ),
        ]
      );
      tableRows.add(tableRow);

      if (rowDivider != null) {
        tableRows.add(TableRow(
          children: [
            rowDivider!,
            rowDivider!
          ]
        ));
      }
    }

    return Table(
      columnWidths: columnWidths,
      children: tableRows,
    );
  }
}
