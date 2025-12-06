import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_item.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_operator_dropdown.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class EnumFilter<T> extends StatelessWidget {
  final String title;
  final List<T> values;
  final T? selected;
  final FilterOperator op;
  final ValueChanged<T?> onChanged;
  final ValueChanged<FilterOperator> onOpChanged;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const EnumFilter({
    required this.title,
    required this.values,
    required this.selected,
    required this.op,
    required this.onChanged,
    required this.onOpChanged,
    required this.isExpanded,
    required this.onExpansionChanged,
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

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return "${s[0].toUpperCase()}${s.substring(1)}";
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
              options: const [FilterOperator.equals, FilterOperator.notEquals],
              selected: op,
              onChanged: onOpChanged,
              getLabel: _getSelectLabel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<T>(
              // ignore: deprecated_member_use
              value: selected,
              items: values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(_capitalize(e.toString().split('.').last)),
                    ),
                  )
                  .toList(),
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
