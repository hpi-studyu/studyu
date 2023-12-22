import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class DashboardScaffold extends StatelessWidget {
  static const double compactWidthThreshold = 800;
  const DashboardScaffold({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < compactWidthThreshold;
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.faded(0.75),
        appBar: isCompact
            ? AppBar(
                title: Text(tr.studyu),
              )
            : null,
        drawer: isCompact ? const AppDrawer() : null,
        body: TwoColumnLayout(
          leftWidget: isCompact ? const SizedBox.shrink() : const AppDrawer(),
          rightWidget: body,
          dividerWidget: const VerticalDivider(
            width: 1,
            thickness: 0.3,
          ),
          scrollLeft: false,
          scrollRight: true,
          paddingLeft: null,
        ));
  }
}
