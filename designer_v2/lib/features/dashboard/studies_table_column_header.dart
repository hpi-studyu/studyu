import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

class StudiesTableColumnHeader extends StatefulWidget {
  final String title;
  final bool sortable;
  final bool sortAscending;
  final bool sortingActive;
  final bool filterable;
  final List<String>? filterOptions;
  final void Function()? onSort;
  final void Function(String)? onFilter;

  const StudiesTableColumnHeader(
    this.title, {
    super.key,
    required this.sortable,
    required this.sortingActive,
    required this.sortAscending,
    required this.filterable,
    this.filterOptions,
    this.onSort,
    this.onFilter,
  });

  @override
  State<StudiesTableColumnHeader> createState() =>
      _StudiesTableColumnHeaderState();
}

class _StudiesTableColumnHeaderState extends State<StudiesTableColumnHeader> {
  bool isHovering = false;
  OverlayEntry? _overlayEntry;
  static OverlayEntry? _activeOverlayEntry;

  // State variable to hold the selected options
  List<String> selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseEventsRegion(
      builder: (context, state) {
        return Row(
          children: [
            Flexible(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
            if (widget.filterable)
              GestureDetector(
                onTap: () => _showFilterDialog(context, widget.filterOptions!),
                child: _getIconFilterable(),
              )
            else if (widget.sortable)
              _getIconSortable() ?? const SizedBox(width: 17)
            else
              const SizedBox.shrink(),
          ],
        );
      },
      onEnter: (event) => setState(() => isHovering = true),
      onExit: (event) => setState(() => isHovering = false),
      onTap: widget.sortable ? () => widget.onSort?.call() : null,
    );
  }

  Icon? _getIconSortable() {
    final ascendingIcon = Icon(MdiIcons.arrowUp);
    final descendingIcon = Icon(MdiIcons.arrowDown);
    final hoveredAscendingIcon = Icon(MdiIcons.arrowUp, color: Colors.grey);
    final hoveredDescendingIcon = Icon(MdiIcons.arrowDown, color: Colors.grey);

    if (!widget.sortable) {
      return null;
    }

    if (!widget.sortingActive) {
      return isHovering
          ? (widget.sortAscending
              ? hoveredAscendingIcon
              : hoveredDescendingIcon)
          : null;
    }

    return widget.sortAscending ? ascendingIcon : descendingIcon;
  }

  void _showFilterDialog(BuildContext context, List<String> filterOptions) {
    // Remove any existing active overlay entry
    _activeOverlayEntry?.remove();
    _activeOverlayEntry = null;

    // Initialize selectedOptions with the existing state if not empty
    if (selectedOptions.isEmpty) {
      selectedOptions = [];  // Could populate from existing filter state
    }

    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _activeOverlayEntry = _createOverlayEntry(context, offset, filterOptions);
    Overlay.of(context).insert(_activeOverlayEntry!);
  }

  OverlayEntry _createOverlayEntry(
      BuildContext context, Offset offset, List<String> filterOptions) {
    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + 30,
        width: 200,
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                ),
              ],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // List of options with checkboxes
                    Column(
                      children: filterOptions.map((option) {
                        return CheckboxListTile(
                          title: Text(option),
                          value: selectedOptions.contains(option),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedOptions.add(option);
                              } else {
                                selectedOptions.remove(option);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _activeOverlayEntry?.remove();
                            _activeOverlayEntry = null;
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onFilter?.call(selectedOptions.join(','));
                            _activeOverlayEntry?.remove();
                            _activeOverlayEntry = null;
                          },
                          child: const Text('Filter'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Icon? _getIconFilterable() {
    final filterIcon = Icon(MdiIcons.filter);
    final hoveredFilterIcon = Icon(MdiIcons.filter, color: Colors.grey);

    if (!widget.filterable) {
      return null;
    }

    return isHovering ? filterIcon : hoveredFilterIcon;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}
