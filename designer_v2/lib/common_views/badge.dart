import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';

enum BadgeType { filled, outlined, outlineFill, plain }

class Badge extends StatelessWidget {
  const Badge({
    required this.label,
    this.labelStyle,
    this.icon = Icons.circle_rounded,
    this.iconSize,
    this.color,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
    this.type = BadgeType.plain,
    super.key,
  });

  final IconData? icon;
  final Color? color;
  final double borderRadius;
  final String label;
  final BadgeType type;
  final EdgeInsets padding;
  final double? iconSize;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicWidth(
        child: Container(
      decoration: BoxDecoration(
        color: Colors.white, // solid background to paint over
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(theme),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          border: Border.all(color: _getBorderColor(theme)),
        ),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (icon != null)
                  ? Icon(
                      icon,
                      size: iconSize ?? ((theme.iconTheme.size ?? 14.0) * 0.8),
                      color: _getLabelColor(theme)?.faded(0.65),
                    )
                  : const SizedBox.shrink(),
              (icon != null) ? const SizedBox(width: 8.0) : const SizedBox.shrink(),
              Text(
                label,
                softWrap: false,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(
                      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 14.0) * 0.95,
                      color: _getLabelColor(theme),
                      fontWeight: FontWeight.bold,
                    )
                    .merge(labelStyle),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Color? _getBackgroundColor(ThemeData theme) {
    final actualColor = color ?? theme.colorScheme.secondary;

    switch (type) {
      case BadgeType.filled:
        return actualColor;
      case BadgeType.outlineFill:
        return actualColor.faded(0.1);
      case BadgeType.outlined:
        return null;
      case BadgeType.plain:
        return null;
    }
  }

  Color _getBorderColor(ThemeData theme) {
    final actualColor = color ?? theme.colorScheme.secondary;

    switch (type) {
      case BadgeType.filled:
        return Colors.transparent;
      case BadgeType.outlineFill:
        return actualColor.faded(0.1);
      case BadgeType.outlined:
        return actualColor.faded(0.1);
      case BadgeType.plain:
        return Colors.transparent;
    }
  }

  Color? _getLabelColor(ThemeData theme) {
    final actualColor = color ?? theme.colorScheme.secondary;

    switch (type) {
      case BadgeType.filled:
        return theme.textTheme.labelLarge?.color?.withOpacity(0.6);
      case BadgeType.outlineFill:
        return actualColor.faded(0.8);
      case BadgeType.outlined:
        return actualColor.faded(0.8);
      case BadgeType.plain:
        return actualColor.faded(0.8);
    }
  }
}
