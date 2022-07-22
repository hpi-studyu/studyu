import 'package:flutter/material.dart';

/// Factory to construct an [InputDecoration] with an empty helper text
///
/// This prevents the height of the widget it is applied to from changing,
/// otherwise [TextField] will grow in height when displaying an error text.
class NullHelperDecoration extends InputDecoration {
  const NullHelperDecoration() : super(helperText: "");
}

class FormTableRow {
  final String label;
  final String? labelHelpText;
  final Widget input;

  FormTableRow({required this.label, this.labelHelpText, required this.input});
}

/// Renders a list of [FormTableRow]s in a two-column tabular layout
class FormTableLayout extends StatelessWidget {
  const FormTableLayout({
    required this.rows,
    this.columnWidths = const {
      0: FixedColumnWidth(160.0),
      1: FlexColumnWidth(),
    },
    Key? key
  }) : super(key: key);

  final List<FormTableRow> rows;
  final Map<int,TableColumnWidth> columnWidths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<TableRow> tableRows = [];
    for (final row in rows) {
      final tableRow = TableRow(
          children: [
            Row(
                children: [
                  Text(row.label, style: theme.textTheme.caption!),
                  (row.labelHelpText != null)
                      ? const SizedBox(width: 8.0) : const SizedBox.shrink(),
                  (row.labelHelpText != null)
                      ? Tooltip(
                      message: row.labelHelpText,
                      child: Icon(
                          Icons.help_outline_rounded,
                          size: theme.textTheme.caption!.fontSize! + 4.0,
                          color: theme.colorScheme.onSurface.withOpacity(0.65)
                      )
                  ) : const SizedBox.shrink(),
                ]
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: row.input,
            )
          ]
      );
      tableRows.add(tableRow);
    }

    return Table(
      columnWidths: columnWidths,
      children: tableRows,
    );
  }
}
