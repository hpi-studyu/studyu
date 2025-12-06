import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_item.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_operator_dropdown.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class BoolFilter extends StatelessWidget {
  final String title;
  final bool? selected;
  final FilterOperator op;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<FilterOperator> onOpChanged;
  final String trueLabel;
  final String falseLabel;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const BoolFilter({
    required this.title,
    required this.selected,
    required this.op,
    required this.onChanged,
    required this.onOpChanged,
    required this.isExpanded,
    required this.onExpansionChanged,
    this.trueLabel = "Yes",
    this.falseLabel = "No",
    Key? key,
  }) : super(key: key);

  String _getSelectLabel(FilterOperator op) {
    switch (op) {
      case FilterOperator.equals:
        return "Is".hardcoded;
      case FilterOperator.notEquals:
        return "Is not".hardcoded;
      default:
        final name = op.name;
        return "${name[0].toUpperCase()}${name.substring(1)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterItem(
      keyName: title,
      title: title,
      isActive: selected != null,
      isInitiallyExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      onReset: () => onChanged(null),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: FilterOperatorDropdown(
              options: const [FilterOperator.equals],
              selected: op,
              onChanged: onOpChanged,
              getLabel: _getSelectLabel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<bool>(
              // ignore: deprecated_member_use
              value: selected,
              items: [
                DropdownMenuItem(value: true, child: Text(trueLabel.hardcoded)),
                DropdownMenuItem(
                  value: false,
                  child: Text(falseLabel.hardcoded),
                ),
              ],
              onChanged: onChanged,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
