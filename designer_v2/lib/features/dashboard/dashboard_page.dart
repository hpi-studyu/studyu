import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_scaffold.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.filters, super.key});

  final List<StudiesFilter>? filters;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final controller = ref.read(dashboardControllerProvider.notifier);
    runAsync(() => controller.setStudiesFilter(widget.filters));
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      final controller = ref.read(dashboardControllerProvider.notifier);
      runAsync(() => controller.setStudiesFilter(widget.filters));
    }
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
              PortalTarget(
                visible: state.createNewMenuOpen,
                portalCandidateLabels: const [outPortalLabel],
                portalFollower: GestureDetector(
                  onTap: () => controller.setCreateNewMenuOpen(false),
                  child: Container(color: Colors.transparent),
                ),
                child: const SizedBox.shrink(),
              ),
              PortalTarget(
                visible: state.createNewMenuOpen,
                anchor: const Aligned(
                  follower: Alignment.topLeft,
                  target: Alignment.bottomLeft,
                ),
                portalFollower: GestureDetector(
                  onTap: () => controller.setCreateNewMenuOpen(false),
                  child: Container(
                    width: 600,
                    margin: const EdgeInsets.only(top: 10.0),
                    child: Material(
                      color: theme.colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 20.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCreateNewDropdownItem(
                              title: tr.action_button_standalone_study_title,
                              subtitle:
                                  tr.action_button_standalone_study_subtitle,
                              onTap: () => controller.onClickNewStudy(false),
                            ),
                            const Divider(
                              height: 0,
                            ),
                            _buildCreateNewDropdownItem(
                              title: tr.action_button_template_title,
                              subtitle: tr.action_button_template_subtitle,
                              hint: tr.action_button_template_hint,
                              onTap: () => controller.onClickNewStudy(true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 36.0,
                  child: PrimaryButton(
                    text: tr.action_button_create,
                    onPressed: () => controller
                        .setCreateNewMenuOpen(!state.createNewMenuOpen),
                  ),
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
          const SizedBox(height: 24.0), // spacing between body elements
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
                    emptyWidget: (widget.filters == null ||
                            widget.filters == DashboardState.defaultFilter)
                        ? (state.query.isNotEmpty)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: Column(
                                  children: [
                                    EmptyBody(
                                      icon: Icons.content_paste_search_rounded,
                                      title: tr.studies_not_found,
                                      description: tr.modify_query,
                                    ),
                                  ],
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

  Widget _buildCreateNewDropdownItem({
    required String title,
    required String subtitle,
    String? hint,
    GestureTapCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.onPrimary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
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
              const SizedBox(
                width: 20,
              ),
              Icon(
                Icons.add,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
