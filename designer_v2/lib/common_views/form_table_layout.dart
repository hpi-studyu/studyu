import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
      final stateColorStyle = (row.control != null && row.control!.disabled)
          ? TextStyle(color: theme.disabledColor)
          : null;
      final actualRowLayout =
          row.layout ?? rowLayout ?? FormTableRowLayout.horizontal;

      final labelWidget = (row.labelBuilder != null)
          ? row.labelBuilder!(context)
          : Wrap(
              children: [
                if (actualRowLayout == FormTableRowLayout.vertical)
                  const SizedBox(width: 2.0)
                else
                  const SizedBox.shrink(),
                FormLabel(
                  labelText: row.label,
                  helpText: row.labelHelpText,
                  labelTextStyle:
                      rowLabelStyle?.merge(row.labelStyle) ?? row.labelStyle,
                  layout: row.layout,
                ),
              ],
            );

      final contentWidget = Align(
        alignment: Alignment.topLeft,
        // Unfortunately need to override the theme here as a workaround to
        // change the text color for disabled controls
        child: Theme(
          data: theme.copyWith(
            textTheme: TextTheme(
              titleMedium: inputTextTheme.merge(stateColorStyle),
            ),
          ),
          child: row.input,
        ),
      );

      final TableRow tableRow;

      if (actualRowLayout == FormTableRowLayout.horizontal) {
        tableRow = TableRow(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: 8.0, right: 8.0, bottom: bottomSpacing),
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
            ),
          ],
        );
      }

      tableRows.add(tableRow);

      if (rowDivider != null) {
        tableRows.add(TableRow(children: [rowDivider!, rowDivider!]));
      }
    }

    return Table(
      columnWidths:
          (rowLayout != null && rowLayout == FormTableRowLayout.vertical)
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
    this.right,
    this.showLock = false,
    this.lockControl,
    this.lockHelpText,
    this.lockedStateText,
    this.unlockedStateText,
    this.divider = true,
    super.key,
  });

  final String title;
  final TextStyle? titleTextStyle;
  final String? helpText;
  final bool divider;
  final bool helpTextDisabled;
  final Widget? right;
  final bool showLock;
  final FormControl<bool>? lockControl;
  final String? lockHelpText;
  final String? lockedStateText;
  final String? unlockedStateText;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FormTableLayout(
                rows: [
                  FormTableRow(
                    label: title,
                    labelHelpText: helpText,
                    labelStyle: titleStyle.merge(titleTextStyle),
                    input: const SizedBox.shrink(),
                  ),
                ],
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                },
              ),
            ),
            if (right != null)
              Row(
                children: [
                  right!,
                  const SizedBox(width: 12.0),
                ],
              )
            else
              const SizedBox.shrink(),
            if (showLock)
              Row(children: [
                ReactiveFormLock(
                  formControl: lockControl,
                  helpText: lockHelpText,
                  lockedStateText: lockedStateText,
                  unlockedStateText: unlockedStateText,
                )
              ])
            else
              const SizedBox.shrink(),
          ],
        ),
        if (divider) const Divider() else const SizedBox.shrink(),
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
        if (labelText != null && layout == FormTableRowLayout.vertical)
          const SizedBox(width: 2.0)
        else
          const SizedBox.shrink(),
        if (labelText != null)
          Text(
            labelText!,
            style: Theme.of(context).textTheme.bodySmall?.merge(labelTextStyle),
          )
        else
          const SizedBox.shrink(),
        if (helpText != null)
          const SizedBox(width: 8.0)
        else
          const SizedBox.shrink(),
        if (helpText != null)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: HelpIcon(tooltipText: helpText),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}

class FormLock extends StatefulWidget {
  const FormLock(
      {super.key,
      required this.locked,
      this.onLockChanged,
      this.readOnly = false,
      this.helpText,
      this.lockedStateText,
      this.unlockedStateText});

  final bool locked;
  final bool readOnly;
  final ValueChanged<bool>? onLockChanged;
  final String? helpText;
  final String? lockedStateText;
  final String? unlockedStateText;

  @override
  State<FormLock> createState() => _FormLockState();
}

class _FormLockState extends State<FormLock> {
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _locked = widget.locked;
  }

  @override
  Widget build(BuildContext context) {
    final lockView = Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: Theme.of(context).disabledColor.withOpacity(0.05)),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Text(
                        widget.locked
                            ? widget.lockedStateText ?? 'Locked'
                            : widget.unlockedStateText ?? 'Unlocked',
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(width: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        _locked ? MdiIcons.lock : MdiIcons.lockOpen,
                        color: _locked
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                        size: 18.0,
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 30,
              child: FittedBox(
                child: Row(
                  children: [
                    Switch(
                      value: _locked,
                      onChanged: widget.readOnly
                          ? null
                          : (value) {
                              setState(() {
                                _locked = value;
                                widget.onLockChanged?.call(_locked);
                              });
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));

    if (widget.helpText != null) {
      return Tooltip(
        message: widget.helpText,
        child: lockView,
      );
    }

    return lockView;
  }
}

class ReactiveFormLock<T> extends ReactiveFormField<bool, bool> {
  ReactiveFormLock({
    super.key,
    super.formControlName,
    super.formControl,
    ReactiveFormFieldCallback<bool>? onChanged,
    String? helpText,
    String? lockedStateText,
    String? unlockedStateText,
  }) : super(
          builder: (field) {
            return FormLock(
              locked: field.value ?? false,
              readOnly: field.control.disabled,
              helpText: helpText,
              lockedStateText: lockedStateText,
              unlockedStateText: unlockedStateText,
              onLockChanged: field.control.enabled
                  ? (value) {
                      field.didChange(value);
                      onChanged?.call(field.control);
                    }
                  : null,
            );
          },
        );
}
