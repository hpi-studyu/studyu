import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class ActionMenuInline extends StatelessWidget {
  const ActionMenuInline({
    required this.actions,
    this.splashRadius = 18.0,
    this.iconSize = 20.0,
    this.iconColor,
    this.visible = true,
    Key? key
  }) : super(key: key);

  final List<ModelAction> actions;
  final MaterialStateProperty<Color>? iconColor;
  final double iconSize;
  final bool visible;
  final double? splashRadius;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty || !visible) {
      return const SizedBox.shrink();
    }

    defaultIconColor(Set<MaterialState> states) {
      final theme = Theme.of(context);
      if (states.contains(MaterialState.hovered)) {
        return theme.colorScheme.secondary.withOpacity(0.8);
      }
      return theme.colorScheme.secondary.withOpacity(0.4);
    }

    final actionButtons = actions.map((action) {
      return Tooltip(
          message: action.label,
          child: MouseEventsRegion(builder: (context, state) {
            return IconButton(
                padding: EdgeInsets.zero,
                splashRadius: splashRadius,
                onPressed: () => action.onExecute(),
                iconSize: iconSize,
                icon: Icon(
                    action.icon,
                    color: iconColor?.resolve(state) ?? (
                        action.isDestructive ? Colors.red : defaultIconColor(state))
                )
            );
          })
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: actionButtons,
    );
  }
}
