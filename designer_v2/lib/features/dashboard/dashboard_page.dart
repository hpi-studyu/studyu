import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/sidenav_layout.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    return SidenavLayout(
        sideDrawerWidget: AppDrawer(title: 'StudyU'.hardcoded),
        mainContentWidget: Scaffold(
          appBar: null, // default app bar not suitable for our layout
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Container(
                    color: Colors.white,
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _contentHeader(context, ref),
                          const SizedBox(height: 24.0),
                          // spacing between body elements
                          AsyncValueWidget<List<Study>>(
                              value: state.visibleStudies,
                              data: (visibleStudies) => StudiesTable(
                                studies: visibleStudies,
                                onSelectStudy: controller.onSelectStudy,
                                getActionsForStudy: controller.getAvailableActionsForStudy,
                              ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }

  Widget _contentHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.watch(dashboardControllerProvider.notifier);

    return Row(
      children: [
        SelectableText("My Studies".hardcoded,
            style: theme.textTheme.headline5
                ?.copyWith(fontWeight: FontWeight.bold)),
        Container(width: 32.0),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            // Foreground color
            onPrimary: Theme.of(context).colorScheme.onPrimary,
            // Background color
            primary: Theme.of(context).colorScheme.primary,
          ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
          icon: const Icon(Icons.add),
          label: Text("New study".hardcoded),
          onPressed: controller.onClickNewStudy
        )
      ],
    );
  }
}
