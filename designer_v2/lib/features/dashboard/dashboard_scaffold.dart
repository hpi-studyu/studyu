import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_designer_v2/common_views/sidenav_layout.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';

class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({required this.body, Key? key}) : super(key: key);

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // default app bar not suitable for our layout
      body: FixedSideScrollBodyLayout(
        sideDrawerWidget: AppDrawer(title: AppLocalizations.of(context)!.study_u),
        mainContentWidget: body,
        ),
      );
  }
}
