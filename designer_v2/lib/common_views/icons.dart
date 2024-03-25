import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

class HelpIcon extends StatelessWidget {
  const HelpIcon({this.tooltipText, super.key});

  final String? tooltipText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltipText,
      child: MouseEventsRegion(
        builder: (context, states) {
          final iconColor = theme.iconTheme.color?.withOpacity((states.contains(MaterialState.hovered)) ? 0.6 : 0.35) ??
              theme.colorScheme.onSurface.withOpacity(0.3);
          return Icon(
            Icons.help_outline_rounded,
            size: theme.textTheme.bodySmall!.fontSize! + 2.0,
            color: iconColor,
          );
        },
      ),
    );
  }
}
