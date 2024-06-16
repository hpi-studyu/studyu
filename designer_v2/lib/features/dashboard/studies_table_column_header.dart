import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:studyu_designer_v2/common_views/mouse_events.dart';

class StudiesTableColumnHeader extends StatefulWidget {
  final String title;
  final bool sortable;
  final bool sortAscending;
  final bool sortingActive;
  final void Function()? onSort;

  const StudiesTableColumnHeader(
    this.title, {
    super.key,
    required this.sortable,
    required this.sortingActive,
    required this.sortAscending,
    this.onSort,
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
            if (widget.sortable)
              _getIcon() ?? const SizedBox(width: 17)
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
}
