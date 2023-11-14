import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class Hyperlink extends StatefulWidget {
  const Hyperlink({
    required this.text,
    this.url,
    this.onClick,
    this.linkColor = const Color(0xFF0000EE),
    this.hoverColor,
    this.visitedColor = const Color(0xFF551A8B),
    this.style,
    this.hoverStyle = const TextStyle(
      decoration: TextDecoration.none, // alternative: TextDecoration.underline
    ),
    this.visitedStyle,
    this.icon,
    this.iconSize,
    super.key,
  }) : assert((url != null && onClick == null) || (url == null && onClick != null),
            "Must provide either url or onClick handler");

  final String text;
  final String? url;
  final VoidCallback? onClick;

  final Color linkColor;
  final Color? hoverColor;
  final Color? visitedColor;

  final TextStyle? style;
  final TextStyle? hoverStyle;
  final TextStyle? visitedStyle;

  final IconData? icon;
  final double? iconSize;

  @override
  State<Hyperlink> createState() => _HyperlinkState();
}

class _HyperlinkState extends State<Hyperlink> {
  bool isVisited = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseEventsRegion(
      builder: (context, states) {
        final isHovered = states.contains(MaterialState.hovered);

        final visitedColor = widget.visitedColor ?? widget.linkColor;
        final visitedHoverColor = widget.hoverColor ?? visitedColor.faded(ThemeConfig.kHoverFadeFactor);
        final hoverColor = widget.hoverColor ?? widget.linkColor.faded(ThemeConfig.kHoverFadeFactor);

        final actualColor =
            isVisited ? (isHovered ? visitedHoverColor : visitedColor) : (isHovered ? hoverColor : widget.linkColor);

        final textTheme = theme.textTheme.titleSmall ?? theme.textTheme.bodyLarge;
        TextStyle? actualStyle = textTheme?.copyWith(color: actualColor).merge(widget.style);

        if (isVisited) {
          actualStyle = actualStyle?.merge(widget.visitedStyle);
        }
        if (isHovered) {
          actualStyle = actualStyle?.merge(widget.hoverStyle);
        }

        final textWidget = Text(widget.text, style: actualStyle);

        if (widget.icon != null) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.icon, color: actualColor, size: widget.iconSize ?? (textTheme?.fontSize ?? 14.0) + 4.0),
              const SizedBox(width: 2.0),
              textWidget
            ],
          );
        }

        return textWidget;
      },
      onTap: () async {
        if (widget.url != null) {
          await launchUrl(Uri.parse(widget.url!));
        }
        widget.onClick?.call();
        setState(() {
          isVisited = true;
        });
      },
    );
  }
}
