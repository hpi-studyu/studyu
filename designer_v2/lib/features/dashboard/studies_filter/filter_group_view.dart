import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_condition_view.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class FilterGroupView extends StatefulWidget {
  final FilterGroup group;
  final VoidCallback onChanged;
  final VoidCallback? onRemove; // Null if root group
  final int depth;

  const FilterGroupView({
    required this.group,
    required this.onChanged,
    this.onRemove,
    this.depth = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<FilterGroupView> createState() => _FilterGroupViewState();
}

class _FilterGroupViewState extends State<FilterGroupView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Theme.of(context).dividerColor, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          ...widget.group.children.map((child) {
            if (child is FilterCondition) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: FilterConditionView(
                  condition: child,
                  onChanged: widget.onChanged,
                  onRemove: () {
                    setState(() {
                      widget.group.children.remove(child);
                    });
                    widget.onChanged();
                  },
                ),
              );
            } else if (child is FilterGroup) {
              return FilterGroupView(
                group: child,
                onChanged: widget.onChanged,
                onRemove: () {
                  setState(() {
                    widget.group.children.remove(child);
                  });
                  widget.onChanged();
                },
                depth: widget.depth + 1,
              );
            }
            return const SizedBox.shrink();
          }).toList(),
          const SizedBox(height: 8),
          _buildAddButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Logic Toggle
        ToggleButtons(
          constraints: const BoxConstraints(minHeight: 24, minWidth: 40),
          isSelected: [
            widget.group.logic == FilterLogic.and,
            widget.group.logic == FilterLogic.or,
          ],
          onPressed: (index) {
            setState(() {
              widget.group.logic = index == 0
                  ? FilterLogic.and
                  : FilterLogic.or;
            });
            widget.onChanged();
          },
          children: const [Text('AND'), Text('OR')],
        ),
        const Spacer(),
        if (widget.onRemove != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.onRemove,
            tooltip: "Remove group".hardcoded,
          ),
      ],
    );
  }

  Widget _buildAddButtons() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              widget.group.add(
                FilterCondition(
                  property: StudyProperty.title, // Default
                  operator: FilterOperator.contains, // Default
                  value: '',
                ),
              );
            });
            widget.onChanged();
          },
          icon: const Icon(Icons.add),
          label: Text("Add Condition".hardcoded),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {
            setState(() {
              widget.group.add(FilterGroup());
            });
            widget.onChanged();
          },
          icon: const Icon(Icons.playlist_add),
          label: Text("Add Group".hardcoded),
        ),
      ],
    );
  }
}
