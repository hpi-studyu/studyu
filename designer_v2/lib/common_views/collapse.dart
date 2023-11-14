import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';

import '../theme.dart';

typedef CollapsibleSectionBuilder = Widget Function(BuildContext context, bool isCollapsed);

/// Simple non-animated & more customizable alternative to [ExpansionPanel]
/// and [ExpansionTile]
///
/// Note: none of the default Flutter widgets can be controlled via a property
/// *and* have the [ExpandIcon] inject into the header be replaced by something
/// more fitting
class Collapsible extends StatefulWidget {
  const Collapsible({
    required this.contentBuilder,
    this.headerBuilder,
    this.title,
    this.isCollapsed = true,
    this.maintainState = true,
    super.key,
  }) : assert((headerBuilder != null && title == null) || (headerBuilder == null && title != null),
            "Must provide either headerBuilder or title");

  final CollapsibleSectionBuilder contentBuilder;
  final CollapsibleSectionBuilder? headerBuilder;
  final String? title;
  final bool isCollapsed;
  final bool maintainState;

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  late bool isCollapsed = widget.isCollapsed;

  @override
  Widget build(BuildContext context) {
    //final defaultTextStyle = DefaultTextStyle.of(context);
    final theme = Theme.of(context);

    final headerWidget = widget.headerBuilder?.call(context, isCollapsed) ??
        MouseEventsRegion(
          builder: (context, states) {
            final isHovered = states.contains(MaterialState.hovered);

            // Use [TabBarThemeData] colors for default header styling
            /*Color? actualColor = isHovered
                ? theme.tabBarTheme.labelColor
                : theme.tabBarTheme.unselectedLabelColor;*/

            return Opacity(
              opacity: isHovered ? ThemeConfig.kHoverFadeFactor : 1.0,
              child: Row(
                children: [
                  FormLabel(
                    labelText: widget.title!,
                    //labelTextStyle: TextStyle(color: actualColor),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    isCollapsed ? Icons.keyboard_arrow_right_rounded : Icons.keyboard_arrow_down_rounded,
                    color: theme.tabBarTheme.labelColor?.faded(ThemeConfig.kMuteFadeFactor),
                  ),
                ],
              ),
            );
          },
          onTap: () => setState(() {
            isCollapsed = !isCollapsed;
          }),
        );

    final contentWidget = widget.contentBuilder(context, isCollapsed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerWidget,
        !isCollapsed ? contentWidget : const SizedBox.shrink(),
      ],
    );
  }
}
