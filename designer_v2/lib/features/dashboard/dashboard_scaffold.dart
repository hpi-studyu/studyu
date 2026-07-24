import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/assets.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';

class DashboardScaffold extends StatelessWidget {
  static const double compactWidthThreshold = 900;
  const DashboardScaffold({
    required this.body,
    this.endDrawer,
    this.scaffoldKey,
    super.key,
  });

  final Widget body;
  final Widget? endDrawer;
  final Key? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < compactWidthThreshold;
    return Scaffold(
      key: scaffoldKey,
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
        // The dashboard body now scrolls itself via PagedListView, so the
        // outer column must NOT also wrap it in a SingleChildScrollView —
        // a self-scrolling list inside another scrollable would lose
        // virtualization (rows would all be laid out at once).
        scrollRight: false,
        scrollLeft: false,
        paddingLeft: null,
      ),
    );
  }
}
