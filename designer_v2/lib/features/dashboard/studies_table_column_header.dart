import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

class StudiesTableColumnHeader extends StatefulWidget {
  final String title;
  final bool sortable;
  final bool sortAscending;
  final bool sortingActive;
  final void Function()? onSort;
  final bool center;

  const StudiesTableColumnHeader(
    this.title, {
    super.key,
    required this.sortable,
    required this.sortingActive,
    required this.sortAscending,
    this.onSort,
    this.center = false,
  });

  @override
  State<StudiesTableColumnHeader> createState() =>
      _StudiesTableColumnHeaderState();
}

class _StudiesTableColumnHeaderState extends State<StudiesTableColumnHeader> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseEventsRegion(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: widget.center
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                textAlign: widget.center ? TextAlign.center : TextAlign.start,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            if (widget.sortable)
              _getIcon() ?? const SizedBox.shrink()
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

  Icon? _getIcon() {
    const ascendingIcon = Icon(MdiIcons.arrowUp);
    const descendingIcon = Icon(MdiIcons.arrowDown);
    const hoveredAscendingIcon = Icon(MdiIcons.arrowUp, color: Colors.grey);
    const hoveredDescendingIcon = Icon(MdiIcons.arrowDown, color: Colors.grey);

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
}
