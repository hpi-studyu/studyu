import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_scaffold.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.filter, super.key});

  final StudiesFilter? filter;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final controller = ref.read(dashboardControllerProvider.notifier);
    runAsync(() => controller.setStudiesFilter(widget.filter));
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      final controller = ref.read(dashboardControllerProvider.notifier);
      runAsync(() => controller.setStudiesFilter(widget.filter));
    }
  }

  final GlobalKey _createMenuButtonKey = GlobalKey();

  void _showDropdownMenu(BuildContext context,
      {required DashboardController controller}) {
    final RenderBox button =
        _createMenuButtonKey.currentContext!.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          button.size.bottomLeft(Offset(0, 10)),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(Offset(0, 10)),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        _buildCreatePopupMenuItem(
          title: tr.action_button_standalone_study_title,
          subtitle: tr.action_button_standalone_study_subtitle,
          onTap: () => controller.onClickNewStudy(false),
        ),
        _buildCreatePopupMenuItem(
          title: tr.action_button_template_title,
          subtitle: tr.action_button_template_subtitle,
          hint: tr.action_button_template_hint,
          onTap: () => controller.onClickNewStudy(true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    return DashboardScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              SizedBox(
                key: _createMenuButtonKey,
                height: 36.0,
                child: PrimaryButton(
                  text: tr.action_button_create,
                  onPressed: () =>
                      _showDropdownMenu(context, controller: controller),
                ),
              ),
              const SizedBox(width: 28.0),
              SelectableText(
                state.visibleListTitle,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(width: 28.0),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Search(
                      searchController: controller.searchController,
                      hintText: tr.search,
                      onQueryChanged: (query) =>
                          controller.filterStudies(query),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          FutureBuilder<StudyUUser>(
            future: ref.read(userRepositoryProvider).fetchUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final pinnedStudies = snapshot.data!.preferences.pinnedStudies;
                return AsyncValueWidget<List<StudyGroup>>(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  value: state.displayedStudies(pinnedStudies: pinnedStudies),
                  data: (visibleStudies) => StudiesTable(
                    studyGroups: visibleStudies,
                    pinnedStudies: pinnedStudies,
                    expandedStudies: state.expandedStudies,
                    dashboardController:
                        ref.watch(dashboardControllerProvider.notifier),
                    onSelect: controller.onSelectStudy,
                    onExpand: controller.onExpandStudy,
                    getActions: controller.availableActions,
                    getSubActions: controller.availableSubActions,
                    emptyWidget: (widget.filter == null ||
                            widget.filter == StudiesFilter.owned)
                        ? (state.query.isNotEmpty)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: EmptyBody(
                                  icon: Icons.content_paste_search_rounded,
                                  title: tr.studies_not_found,
                                  description: tr.modify_query,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: EmptyBody(
                                  icon: Icons.content_paste_search_rounded,
                                  title: tr.studies_empty,
                                  description: tr.studies_empty_description,
                                  // "...or create a new draft copy from an already published study!",
                                  /* button: PrimaryButton(text: "From template",); */
                                ),
                              )
                        : const SizedBox.shrink(),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildCreateNewDropdownItem({
  //   required String title,
  //   required String subtitle,
  //   String? hint,
  //   GestureTapCallback? onTap,
  // }) {
  //   final theme = Theme.of(context);
  //   return Material(
  //     color: theme.colorScheme.onPrimary,
  //     child: InkWell(
  //       onTap: onTap,
  //       child: Container(
  //         padding: const EdgeInsets.all(20),
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     title,
  //                     style: theme.textTheme.titleMedium
  //                         ?.copyWith(color: theme.colorScheme.primary),
  //                   ),
  //                   Text(subtitle),
  //                   if (hint != null)
  //                     Padding(
  //                       padding: const EdgeInsets.only(top: 8),
  //                       child: Text(
  //                         hint,
  //                         style: const TextStyle(fontStyle: FontStyle.italic),
  //                       ),
  //                     )
  //                   else
  //                     const SizedBox.shrink(),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(
  //               width: 20,
  //             ),
  //             Icon(
  //               Icons.add,
  //               color: theme.colorScheme.primary,
  //               size: 28,
  //             ),
  //             const SizedBox(
  //               width: 8,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  PopupMenuItem _buildCreatePopupMenuItem({
    required String title,
    required String subtitle,
    String? hint,
    GestureTapCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return PopupMenuItem(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: theme.colorScheme.primary),
                      ),
                      Text(subtitle),
                      if (hint != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            hint,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
            const Divider()
          ],
        ));
  }
}
