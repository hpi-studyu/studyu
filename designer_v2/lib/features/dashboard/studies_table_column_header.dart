import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../common_views/mouse_events.dart';

class StudiesTableColumnHeader extends StatefulWidget {
  final String title;
  final bool sortable;
  final bool sortAscending;
  final bool sortingActive;
  final void Function()? onSort;

  const StudiesTableColumnHeader(this.title,
      {super.key,
      required this.sortable,
      required this.sortingActive,
      required this.sortAscending,
      this.onSort});

  @override
  State<StudiesTableColumnHeader> createState() => _StudiesTableColumnHeaderState();
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
            Text(
              widget.title,
              overflow: TextOverflow.visible,
              maxLines: 1,
              softWrap: false,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            _buildSortingArrow(),
          ],
        );
      },
      onEnter: (event) => setState(() => isHovering = true),
      onExit: (event) => setState(() => isHovering = false),
      onTap: widget.sortable ? () => widget.onSort?.call() : null,
    );
  }

  Widget _buildSortingArrow() {
    if (!widget.sortable) {
      return const SizedBox.shrink();
    }

    if (!widget.sortingActive && !isHovering) {
      return const SizedBox(
        width: 17,
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: widget.sortingActive ? 1.0 : 0.5,
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 250),
        turns: widget.sortAscending ? 0 : 0.5,
        child: Icon(MdiIcons.arrowUp),
      ),
    );
  }
}
