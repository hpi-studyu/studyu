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
import 'package:studyu_designer_v2/utils/performance.dart';

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
    runAsync(() => controller.setStudiesFilter(widget.filter));
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      runAsync(() => controller.setStudiesFilter(widget.filter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    return DashboardScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              PrimaryButton(
                icon: Icons.add,
                text: tr.action_button_new_study,
                onPressed: controller.onClickNewStudy,
              ),
              const SizedBox(width: 28.0),
              SelectableText(state.visibleListTitle, style: theme.textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 24.0), // spacing between body elements
          AsyncValueWidget<List<Study>>(
            value: state.visibleStudies,
            data: (visibleStudies) => StudiesTable(
              studies: visibleStudies,
              onSelect: controller.onSelectStudy,
              getActions: controller.availableActions,
              emptyWidget: (widget.filter == null || widget.filter == StudiesFilter.owned)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: EmptyBody(
                        icon: Icons.content_paste_search_rounded,
                        title: "You don't have any studies yet",
                        description:
                            "Build your own study from scratch, start from the default template or create a new draft copy from an already published study!",
                        button: PrimaryButton(
                          text: "From template",
                          onPressed: () {
                            print("TODO");
                          },
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          )
        ],
      ),
    );
  }
}
