import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

typedef ActionsProvider<T> = List<ModelAction> Function();
typedef ActionsProviderFor<T> = List<ModelAction> Function(T from);
typedef ActionsProviderAt<T> = List<ModelAction> Function(T from, int idx);

class ActionPopUpMenuButton extends StatelessWidget {
  const ActionPopUpMenuButton(
      {required this.actions,
      this.orientation = Axis.horizontal,
      this.elevation = 5,
      this.splashRadius = 24.0,
      this.triggerIconSize = 18.0,
      this.position = PopupMenuPosition.under,
      this.triggerIconColor,
      this.triggerIconColorHover,
      this.disableSplashEffect = false,
      this.hideOnEmpty = true,
      this.enabled = true,
      super.key});

  final List<ModelAction> actions;
  final Color? triggerIconColor;
  final Color? triggerIconColorHover;
  final double triggerIconSize;
  final bool disableSplashEffect;
  final bool hideOnEmpty;
  final Axis orientation;
  final double? elevation;
  final double? splashRadius;
  final bool enabled;
  final PopupMenuPosition position;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return MouseEventsRegion(builder: (context, state) {
      Widget widget = _buildPopupMenu(context, state);

      if (disableSplashEffect) {
        final popupMenu = widget;
        widget = Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: popupMenu);
      }

      return widget;
    });
  }

  Widget _buildPopupMenu(BuildContext context, Set<MaterialState> state) {
    final theme = Theme.of(context);
    final isHovered = state.contains(MaterialState.hovered);
    final iconColorDefault = triggerIconColor ?? theme.iconTheme.color!.withOpacity(0.7);
    final iconColorHover = triggerIconColorHover ?? theme.iconTheme.color!.withOpacity(0.7);
    final triggerIcon = (orientation == Axis.vertical) ? Icons.more_vert_rounded : Icons.more_horiz_rounded;

    return PopupMenuButton(
        icon: Icon(triggerIcon, size: triggerIconSize, color: (isHovered) ? iconColorHover : iconColorDefault),
        enabled: enabled,
        elevation: elevation,
        splashRadius: splashRadius,
        position: position,
        onSelected: (ModelAction action) => action.onExecute(),
        itemBuilder: (BuildContext context) {
          final textTheme = theme.textTheme.labelMedium!;
          return actions.map((action) {
            return PopupMenuItem(
              value: action,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                horizontalTitleGap: 4.0,
                leading: (action.icon == null)
                    ? const SizedBox.shrink()
                    : Icon(action.icon,
                        size: theme.iconTheme.size ?? 14.0,
                        color: action.isDestructive ? Colors.red : iconColorDefault),
                title: action.isDestructive
                    ? Text(action.label, style: textTheme.copyWith(color: Colors.red))
                    : Text(action.label, style: textTheme),
              ),
            );
          }).toList();
        });
  }
}
