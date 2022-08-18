import 'package:flutter/widgets.dart';

List<Widget> withSpacing(List<Widget> widgets, {
  required double spacing, double? paddingStart, double? paddingEnd}) {
  final List<Widget> results = [];
  if (paddingStart != null) {
    results.add(SizedBox(height: paddingStart, width: paddingStart));
  }
  for (var i = 0; i < widgets.length; i++) {
    final isTrailing = i == widgets.length - 1;
    results.add(widgets[i]);
    if (!isTrailing) {
      results.add(SizedBox(height: spacing, width: spacing));
    }
  }
  if (paddingEnd != null) {
    results.add(SizedBox(height: paddingEnd, width: paddingEnd));
  }
  return results;
}

/// Allows the wrapped [widget] to retain its preferred size & avoid
///  being stretched when placed into the [AppBar] actions
///  Note: [AppBar] places the actions in a [CrossAxisAlignment.stretched] row
Widget retainSizeInAppBar(Widget widget) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [widget],
  );
}
