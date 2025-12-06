import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class FilterItem extends StatefulWidget {
  final String keyName;
  final String title;
  final Widget child;
  final bool isActive;
  final VoidCallback? onReset;
  final bool isInitiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const FilterItem({
    required this.keyName,
    required this.title,
    required this.child,
    required this.isActive,
    this.onReset,
    this.isInitiallyExpanded = false,
    this.onExpansionChanged,
    super.key,
  });

  @override
  State<FilterItem> createState() => _FilterItemState();
}

class _FilterItemState extends State<FilterItem> {
  // We keep internal state for expansion if no external controller is used,
  // but the original code used a Set<String> _expandedFields passed down (implicitly or explicitly).
  // The original _buildFilterItem took a 'key' and checked against _expandedFields.
  // Ideally, we want this widget to be pure or manage its own expansion if it's not critical to lift it up.
  // In the original code, `_expandedFields` was only used to expand/collapse.
  // Let's rely on the parent checking `_expandedFields` and passing `isInitiallyExpanded`.
  // Wait, the original code had setState(() => _expandedFields.add(key)).
  // So we need a callback to toggle expansion.

  @override
  Widget build(BuildContext context) {
    // We'll trust the parent to pass the correct expanded state
    final isExpanded = widget.isInitiallyExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: isExpanded
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            )
          : null,
      padding: isExpanded ? const EdgeInsets.all(8) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (!isExpanded)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () {
                    widget.onExpansionChanged?.call(true);
                  },
                  tooltip: "Add filter".hardcoded,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  color: Theme.of(context).colorScheme.primary,
                )
              else
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () {
                    widget.onExpansionChanged?.call(false);
                    widget.onReset?.call();
                  },
                  tooltip: "Remove filter".hardcoded,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  color: Theme.of(context).colorScheme.error,
                ),
              const SizedBox(width: 6),
            ],
          ),
          if (isExpanded) ...[const SizedBox(height: 8), widget.child],
        ],
      ),
    );
  }
}
