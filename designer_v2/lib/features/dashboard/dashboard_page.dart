import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_scaffold.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.filter, Key? key}) : super(key: key);

  final StudiesFilter? filter;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = ref.read(dashboardControllerProvider.notifier);
    controller.setStudiesFilter(widget.filter);
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      Future.delayed(const Duration(milliseconds: 0),
          () => controller.setStudiesFilter(widget.filter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);
    print("DashboardScreen.build");

    return DashboardScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              PrimaryButton(
                icon: Icons.add,
                text: tr.new_study,
                onPressed: controller.onClickNewStudy,
              ),
              Container(width: 32.0),
              SelectableText(state.visibleListTitle,
                  style: theme.textTheme.headline5?.copyWith(
                      fontWeight: FontWeight.bold)),
              Container(width: 32.0),
            ],
          ),
          const SizedBox(height: 24.0), // spacing between body elements
          AsyncValueWidget<List<Study>>(
            value: state.visibleStudies,
            data: (visibleStudies) => StudiesTable(
              studies: visibleStudies,
              onSelectStudy: controller.onSelectStudy,
              getActionsForStudy: controller.availableActions,
            ),
            empty: () => EmptyBody(
              icon: Icons.folder_open_rounded,
              title: tr.nothing_here_yet, // TODO: proper empty text
              description: tr.lorem_ipsum,
            ),
          )
        ],
      ),
    );
  }
}
