import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class FilterConditionView extends ConsumerStatefulWidget {
  final FilterCondition condition;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const FilterConditionView({
    required this.condition,
    required this.onChanged,
    required this.onRemove,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FilterConditionView> createState() =>
      _FilterConditionViewState();
}

class _FilterConditionViewState extends ConsumerState<FilterConditionView> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.condition.value?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(FilterConditionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.condition.value != oldWidget.condition.value) {
      // Update text controller if value changed externally, but avoid cursor jumps if possible
      if (_textController.text != widget.condition.value?.toString()) {
        _textController.text = widget.condition.value?.toString() ?? '';
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Property Dropdown
        DropdownButton<StudyProperty>(
          value: widget.condition.property,
          items: StudyProperty.values.map((prop) {
            return DropdownMenuItem(
              value: prop,
              child: Text(prop.name.capitalize()), // TODO: Localize
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                widget.condition.property = value;
                // Reset operator and value if incompatible?
                // For simplicity, let's keep it or set default
              });
              widget.onChanged();
            }
          },
        ),
        const SizedBox(width: 8),
        // Operator Dropdown
        DropdownButton<FilterOperator>(
          value: widget.condition.operator,
          items: FilterOperator.values.map((op) {
            return DropdownMenuItem(
              value: op,
              child: Text(op.name), // TODO: Localize and format
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                widget.condition.operator = value;
              });
              widget.onChanged();
            }
          },
        ),
        const SizedBox(width: 8),
        // Value Input
        Expanded(child: _buildValueInput()),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: widget.onRemove,
          tooltip: "Remove condition".hardcoded,
        ),
      ],
    );
  }

  Widget _buildValueInput() {
    // TODO: Switch based on property type (Date picker, Number input, etc.)
    // For now, simple text input
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText: "Value".hardcoded,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        widget.condition.value = value;
        widget.onChanged();
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
