import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/icons.dart';

enum FormTableRowLayout { vertical, horizontal }

class FormTableRow {
  FormTableRow({
    this.label,
    this.labelBuilder,
    required this.input,
    this.labelStyle,
    this.labelHelpText,
    this.control,
    this.layout,
  });

  final String? label;
  final WidgetBuilder? labelBuilder;
  final TextStyle? labelStyle;
  final String? labelHelpText;
  final Widget input;
  final AbstractControl? control;
  final FormTableRowLayout? layout;
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
    this.rowLayout = FormTableRowLayout.horizontal,
    this.rowLabelStyle,
    super.key,
  });

  final List<FormTableRow> rows;
  final Map<int, TableColumnWidth> columnWidths;
  final Widget? rowDivider;
  final FormTableRowLayout? rowLayout;
  final TextStyle? rowLabelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Flutter uses "theme.textTheme.titleMedium" for input fields by default
    final inputTextTheme = theme.textTheme.titleMedium!;

    final List<TableRow> tableRows = [];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final isTrailing = i == rows.length - 1;

      final bottomSpacing = (!isTrailing) ? 10.0 : 0.0;
      final stateColorStyle =
          (row.control != null && row.control!.disabled) ? TextStyle(color: theme.disabledColor) : null;
      final actualRowLayout = row.layout ?? rowLayout ?? FormTableRowLayout.horizontal;

      final labelWidget = (row.labelBuilder != null)
          ? row.labelBuilder!(context)
          : Wrap(
              children: [
                (actualRowLayout == FormTableRowLayout.vertical) ? const SizedBox(width: 2.0) : const SizedBox.shrink(),
                FormLabel(
                  labelText: row.label,
                  helpText: row.labelHelpText,
                  labelTextStyle: rowLabelStyle?.merge(row.labelStyle) ?? row.labelStyle,
                  layout: row.layout,
                ),
              ],
            );

      final contentWidget = Align(
        alignment: Alignment.topLeft,
        // Unfortunately need to override the theme here as a workaround to
        // change the text color for disabled controls
        child: Theme(
          data: theme.copyWith(textTheme: TextTheme(titleMedium: inputTextTheme.merge(stateColorStyle))),
          child: row.input,
        ),
      );

      final TableRow tableRow;

      if (actualRowLayout == FormTableRowLayout.horizontal) {
        tableRow = TableRow(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, right: 8.0, bottom: bottomSpacing),
              child: labelWidget,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: bottomSpacing),
              child: contentWidget,
            ),
          ],
        );
      } else {
        // actualRowLayout == FormTableRowLayout.vertical
        tableRow = TableRow(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  labelWidget,
                  const SizedBox(height: 8.0),
                  Container(
                    padding: EdgeInsets.only(bottom: bottomSpacing * 2),
                    child: contentWidget,
                  ),
                ],
              ),
            )
          ],
        );
      }

      tableRows.add(tableRow);

      if (rowDivider != null) {
        tableRows.add(TableRow(children: [rowDivider!, rowDivider!]));
      }
    }

    return Table(
      columnWidths: (rowLayout != null && rowLayout == FormTableRowLayout.vertical)
          ? const {
              0: FlexColumnWidth(),
              1: FixedColumnWidth(0.0),
            }
          : columnWidths,
      children: tableRows,
    );
  }
}

class FormSectionHeader extends StatelessWidget {
  const FormSectionHeader({
    required this.title,
    this.helpText,
    this.helpTextDisabled = false,
    this.titleTextStyle,
    this.divider = true,
    super.key,
  });

  final String title;
  final TextStyle? titleTextStyle;
  final String? helpText;
  final bool divider;
  final bool helpTextDisabled;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge!;

    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              label: title,
              labelHelpText: helpText,
              labelStyle: titleStyle.merge(titleTextStyle),
              input: Container(),
            ),
          ],
          columnWidths: const {
            0: IntrinsicColumnWidth(),
          },
        ),
        (divider) ? const Divider() : const SizedBox.shrink(),
      ],
    );
  }
}

class FormLabel extends StatelessWidget {
  const FormLabel({
    this.labelText,
    this.helpText,
    this.labelTextStyle,
    this.layout = FormTableRowLayout.vertical,
    super.key,
  });

  final String? labelText;
  final String? helpText;
  final TextStyle? labelTextStyle;
  final FormTableRowLayout? layout;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        (labelText != null && layout == FormTableRowLayout.vertical)
            ? const SizedBox(width: 2.0)
            : const SizedBox.shrink(),
        (labelText != null)
            ? Text(
                labelText!,
                style: Theme.of(context).textTheme.bodySmall?.merge(labelTextStyle),
              )
            : const SizedBox.shrink(),
        (helpText != null) ? const SizedBox(width: 8.0) : const SizedBox.shrink(),
        (helpText != null)
            ? Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: HelpIcon(tooltipText: helpText),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
