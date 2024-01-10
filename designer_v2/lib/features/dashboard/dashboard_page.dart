import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
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

import '../../constants.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.filter, super.key});

  final StudiesFilter? filter;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final DashboardController controller;
  late final DashboardState state;

  @override
  void initState() {
    super.initState();
    controller = ref.read(dashboardControllerProvider.notifier);
    state = ref.read(dashboardControllerProvider);
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
    final userRepo = ref.watch(userRepositoryProvider);

    return DashboardScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                  child: const SizedBox.shrink()),
              PortalTarget(
                visible: state.createNewMenuOpen,
                anchor: const Aligned(follower: Alignment.topLeft, target: Alignment.bottomLeft),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCreateNewDropdownItem(
                              title: tr.action_button_standalone_study_title,
                              subtitle: tr.action_button_standalone_study_subtitle,
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
                child: PrimaryButton(
                  icon: Icons.add,
                  text: tr.action_button_create,
                  onPressed: () => controller.setCreateNewMenuOpen(!state.createNewMenuOpen),
                ),
              ),
              const SizedBox(width: 28.0),
              SelectableText(state.visibleListTitle, style: theme.textTheme.headlineMedium),
              const SizedBox(width: 28.0),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Search(
                            searchController: controller.searchController,
                            hintText: tr.search,
                            onQueryChanged: (query) => controller.filterStudies(query)),
                      ))),
            ],
          ),
          const SizedBox(height: 24.0), // spacing between body elements
          FutureBuilder<StudyUUser>(
              future: userRepo.fetchUser(), // todo cache this with ModelRepository
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return AsyncValueWidget<List<StudyGroup>>(
                      value: state.displayedStudies(snapshot.data!.preferences.pinnedStudies, state.query),
                      data: (visibleStudies) => StudiesTable(
                            studyGroups: visibleStudies,
                            pinnedStudies: snapshot.data!.preferences.pinnedStudies,
                            dashboardController: ref.read(dashboardControllerProvider.notifier),
                            onSelect: controller.onSelectStudy,
                            getActions: controller.availableActions,
                            getSubActions: controller.availableSubActions,
                            emptyWidget: (widget.filter == null || widget.filter == StudiesFilter.owned)
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
                          ));
                }
                return const SizedBox.shrink();
              }),
        ],
      ),
    );
  }

  Widget _buildCreateNewDropdownItem(
      {required String title, required String subtitle, String? hint, GestureTapCallback? onTap}) {
    final theme = Theme.of(context);
    return Material(
      elevation: 0,
      color: theme.colorScheme.onPrimary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                  ),
                  Text(subtitle),
                  hint != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            hint,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              )),
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
