import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_item.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_operator_dropdown.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class NumberFilter extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FilterOperator op;
  final ValueChanged<FilterOperator> onOpChanged;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const NumberFilter({
    required this.title,
    required this.controller,
    required this.op,
    required this.onOpChanged,
    required this.isExpanded,
    required this.onExpansionChanged,
    Key? key,
  }) : super(key: key);

  String _getNumberLabel(FilterOperator op) {
    switch (op) {
      case FilterOperator.greaterThanOrEqual:
        return "Min".hardcoded;
      case FilterOperator.lessThanOrEqual:
        return "Max".hardcoded;
      case FilterOperator.equals:
        return "Exactly".hardcoded;
      case FilterOperator.greaterThan:
        return "More than".hardcoded;
      case FilterOperator.lessThan:
        return "Less than".hardcoded;
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
      isActive: controller.text.isNotEmpty,
      isInitiallyExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      onReset: () => controller.clear(),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: FilterOperatorDropdown(
              options: const [
                FilterOperator.greaterThanOrEqual,
                FilterOperator.lessThanOrEqual,
                FilterOperator.equals,
                FilterOperator.greaterThan,
                FilterOperator.lessThan,
              ],
              selected: op,
              onChanged: onOpChanged,
              getLabel: _getNumberLabel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(),
                hintText: "0",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
