import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/icons.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

class FormTableRow {
  final String label;
  final TextStyle? labelStyle;
  final String? labelHelpText;
  final Widget input;
  final AbstractControl? control;

  FormTableRow({
    required this.label,
    required this.input,
    this.labelStyle,
    this.labelHelpText,
    this.control,
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
    Key? key,
  }) : super(key: key);

  final List<FormTableRow> rows;
  final Map<int, TableColumnWidth> columnWidths;
  final Widget? rowDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Flutter uses "theme.textTheme.subtitle1" for input fields by default
    final inputTextTheme = theme.textTheme.subtitle1!;

    final List<TableRow> tableRows = [];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final isTrailing = i == rows.length - 1;
      final bottomSpacing = (!isTrailing) ? 10.0 : 0.0;

      final stateColorStyle = (row.control != null && row.control!.disabled)
          ? TextStyle(color: theme.disabledColor)
          : null;

      final tableRow = TableRow(children: [
        Container(
          padding: EdgeInsets.only(top: 8.0, bottom: bottomSpacing, right: 8.0),
          child: Wrap(children: [
            Text(
              row.label,
              style: theme.textTheme.caption!.merge(row.labelStyle),
            ),
            (row.labelHelpText != null)
                ? const SizedBox(width: 8.0)
                : const SizedBox.shrink(),
            (row.labelHelpText != null)
                ? Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: HelpIcon(tooltipText: row.labelHelpText),
                  )
                : const SizedBox.shrink(),
          ]),
        ),
        Container(
          padding: EdgeInsets.only(bottom: bottomSpacing),
          child: Align(
            alignment: Alignment.topLeft,
            // Unfortunately need to override the theme here as a workaround to
            // change the text color for disabled controls
            child: Theme(
              data: theme.copyWith(
                  textTheme: TextTheme(
                      subtitle1: inputTextTheme.merge(stateColorStyle))),
              child: row.input,
            ),
          ),
        ),
      ]);
      tableRows.add(tableRow);

      if (rowDivider != null) {
        tableRows.add(TableRow(children: [rowDivider!, rowDivider!]));
      }
    }

    return Table(
      columnWidths: columnWidths,
      children: tableRows,
    );
  }
}

class FormSectionHeader extends StatelessWidget {
  const FormSectionHeader({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(rows: [
          FormTableRow(
            label: title,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            input: Container(),
          ),
        ]),
        const Divider(),
      ],
    );
  }
}
