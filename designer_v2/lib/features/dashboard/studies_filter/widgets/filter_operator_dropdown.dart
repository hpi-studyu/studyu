import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';

class FilterOperatorDropdown extends StatelessWidget {
  final List<FilterOperator> options;
  final FilterOperator selected;
  final ValueChanged<FilterOperator> onChanged;
  final String Function(FilterOperator) getLabel;

  const FilterOperatorDropdown({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.getLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FilterOperator>(
      // ignore: deprecated_member_use
      value: selected,
      items: options
          .map((op) => DropdownMenuItem(value: op, child: Text(getLabel(op))))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(),
      ),
    );
  }
}
