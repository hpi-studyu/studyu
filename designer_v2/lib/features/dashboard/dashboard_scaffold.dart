import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/assets.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';

class DashboardScaffold extends StatelessWidget {
  static const double compactWidthThreshold = 800;
  const DashboardScaffold({required this.body, this.endDrawer, super.key});

  final Widget body;
  final Widget? endDrawer;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < compactWidthThreshold;
    return Scaffold(
      appBar: isCompact
          ? AppBar(title: Image.asset(Assets.logoWide, height: 40))
          : null,
      drawer: isCompact ? const AppDrawer() : null,
      endDrawer: endDrawer,
      body: TwoColumnLayout(
        leftWidget: isCompact
            ? const SizedBox.shrink()
            : const AppDrawer(autoCloseDrawer: false),
        rightWidget: body,
        dividerWidget: const VerticalDivider(width: 1, thickness: 0.3),
        scrollLeft: false,
        paddingLeft: null,
      ),
    );
  }
}
