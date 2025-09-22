import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/domain/advanced_filters_model.dart';
import 'package:studyu_designer_v2/features/advanced_filters/advanced_filters_apply.dart';
import 'package:studyu_designer_v2/features/advanced_filters/advanced_filters_controller.dart';
import 'package:studyu_designer_v2/features/advanced_filters/advanced_filters_entry_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);
    final FilterDraft? activeDraft = ref.watch(activeFilterDraftProvider);

    return DashboardScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row(
          //   children: [
          //     SizedBox(
          //       height: 36.0,
          //       child: PrimaryButton(
          //         text: tr.action_button_new_study,
          //         onPressed: controller.onClickNewStudy,
          //       ),
          //     ),
          //     const SizedBox(width: 28.0),
          //     SelectableText(
          //       state.visibleListTitle,
          //       style: theme.textTheme.headlineMedium,
          //     ),
          //     const SizedBox(width: 28.0),
          //     // Expanded(
          //     //   child: Align(
          //     //     alignment: Alignment.centerRight,
          //     //     child: Container(
          //     //       constraints: const BoxConstraints(maxWidth: 400),
          //     //       child: Search(
          //     //         searchController: state.searchController,
          //     //         hintText: tr.search,
          //     //         onQueryChanged: (query) =>
          //     //             controller.filterStudies(query),
          //     //       ),
          //     //     ),
          //     //   ),
          //     // ),

          //   FutureBuilder<StudyUUser>(
          //       future: ref.read(userRepositoryProvider).fetchUser(),
          //       builder: (context, snapshot) {
          //         if (snapshot.hasData) {
          //           return AsyncValueWidget<List<Study>>(
          //             loading: () => const Center(child: CircularProgressIndicator()),
          //             value: state.displayedStudies(
          //               snapshot.data!.preferences.pinnedStudies,
          //               state.query,
          //             ),
          //             data: (visibleStudies) {
          //               // If an advanced filter is active, apply it here
          //               final meId = _tryGetUserId(snapshot.data);
          //               final meEmail = _tryGetUserEmail(snapshot.data);

          //               final filtered = (activeDraft == null)
          //                   ? visibleStudies
          //                   : visibleStudies
          //                       .where(compileToPredicate(activeDraft, meId: meId, meEmail: meEmail))
          //                       .toList();

          //               return StudiesTable(
          //                 studies: filtered,
          //                 pinnedStudies: snapshot.data!.preferences.pinnedStudies,
          //                 dashboardController: ref.watch(dashboardControllerProvider.notifier),
          //                 onSelect: controller.onSelectStudy,
          //                 getActions: controller.availableActions,
          //                 emptyWidget: (widget.filter == null || widget.filter == StudiesFilter.owned)
          //                     ? (state.query.isNotEmpty || activeDraft != null)
          //                         ? Padding(
          //                             padding: const EdgeInsets.only(top: 24.0),
          //                             child: EmptyBody(
          //                               icon: Icons.content_paste_search_rounded,
          //                               title: tr.studies_not_found,
          //                               description: tr.modify_query, // or “Clear filters”
          //                             ),
          //                           )
          //                         : Padding(
          //                             padding: const EdgeInsets.only(top: 24.0),
          //                             child: EmptyBody(
          //                               icon: Icons.content_paste_search_rounded,
          //                               title: tr.studies_empty,
          //                               description: tr.studies_empty_description,
          //                             ),
          //                           )
          //                     : const SizedBox.shrink(),
          //               );
          //             },
          //           );
          //         }
          //         return const Center(child: CircularProgressIndicator());
          //       },
          //     ),

          //     // Expanded(
          //     //     child: Align(
          //     //     alignment: Alignment.centerRight,
          //     //     child: Row(
          //     //       mainAxisSize: MainAxisSize.min,
          //     //       children: [
          //     //         // New Advanced Filters entry point
          //     //         const AdvancedFiltersEntryButton(),
          //     //         const SizedBox(width: 12),
          //     //         // Existing Search box
          //     //         Container(
          //     //           constraints: const BoxConstraints(maxWidth: 400),
          //     //           child: Search(
          //     //             searchController: state.searchController,
          //     //             hintText: tr.search,
          //     //             onQueryChanged: (query) =>
          //     //                 controller.filterStudies(query),
          //     //           ),
          //     //         ),
          //     //       ],
          //     //     ),
          //     //   ),
          //     // ),
          //   ],
          // ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 36.0,
                child: PrimaryButton(
                  text: tr.action_button_new_study,
                  onPressed: controller.onClickNewStudy,
                ),
              ),
              const SizedBox(width: 16),
              // Title expands; actions stay to the right
              Expanded(
                child: SelectableText(
                  state.visibleListTitle,
                  style: theme.textTheme.headlineMedium,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              // Right-side actions cluster (Advanced Filters + Search)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AdvancedFiltersEntryButton(),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Search(
                      searchController: state.searchController,
                      hintText: tr.search,
                      onQueryChanged: (query) => controller.filterStudies(query),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // const SizedBox(height: 24.0), // spacing between body elements
          // FutureBuilder<StudyUUser>(
          //   future: ref.read(userRepositoryProvider).fetchUser(),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return AsyncValueWidget<List<Study>>(
          //         loading: () =>
          //             const Center(child: CircularProgressIndicator()),
          //         value: state.displayedStudies(
          //           snapshot.data!.preferences.pinnedStudies,
          //           state.query,
          //         ),
          //         data: (visibleStudies) => StudiesTable(
          //           studies: visibleStudies,
          //           pinnedStudies: snapshot.data!.preferences.pinnedStudies,
          //           dashboardController: ref.watch(
          //             dashboardControllerProvider.notifier,
          //           ),
          //           onSelect: controller.onSelectStudy,
          //           getActions: controller.availableActions,
          //           emptyWidget:
          //               (widget.filter == null ||
          //                   widget.filter == StudiesFilter.owned)
          //               ? (state.query.isNotEmpty)
          //                     ? Padding(
          //                         padding: const EdgeInsets.only(top: 24.0),
          //                         child: EmptyBody(
          //                           icon: Icons.content_paste_search_rounded,
          //                           title: tr.studies_not_found,
          //                           description: tr.modify_query,
          //                         ),
          //                       )
          //                     : Padding(
          //                         padding: const EdgeInsets.only(top: 24.0),
          //                         child: EmptyBody(
          //                           icon: Icons.content_paste_search_rounded,
          //                           title: tr.studies_empty,
          //                           description: tr.studies_empty_description,
          //                           // "...or create a new draft copy from an already published study!",
          //                           /* button: PrimaryButton(text: "From template",); */
          //                         ),
          //                       )
          //               : const SizedBox.shrink(),
          //         ),
          //       );
          //     }
          //     return const Center(child: CircularProgressIndicator());
          //   },
          // ),
          const SizedBox(height: 24.0),
          FutureBuilder<StudyUUser>(
            future: ref.read(userRepositoryProvider).fetchUser(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return AsyncValueWidget<List<Study>>(
                loading: () => const Center(child: CircularProgressIndicator()),
                value: state.displayedStudies(
                  snapshot.data!.preferences.pinnedStudies,
                  state.query,
                ),
                data: (visibleStudies) {
                  // Apply advanced filter if active
                  final meId = _tryGetUserId(snapshot.data);
                  final meEmail = _tryGetUserEmail(snapshot.data);

                  final filtered = (activeDraft == null)
                      ? visibleStudies
                      : visibleStudies
                          .where(compileToPredicate(activeDraft, meId: meId, meEmail: meEmail))
                          .toList();

                  return StudiesTable(
                    studies: filtered,
                    pinnedStudies: snapshot.data!.preferences.pinnedStudies,
                    dashboardController: ref.watch(dashboardControllerProvider.notifier),
                    onSelect: controller.onSelectStudy,
                    getActions: controller.availableActions,
                    emptyWidget: (widget.filter == null || widget.filter == StudiesFilter.owned)
                        ? (state.query.isNotEmpty || activeDraft != null)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: EmptyBody(
                                  icon: Icons.content_paste_search_rounded,
                                  title: tr.studies_not_found,
                                  description: tr.modify_query, // maybe “Clear filters”
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: EmptyBody(
                                  icon: Icons.content_paste_search_rounded,
                                  title: tr.studies_empty,
                                  description: tr.studies_empty_description,
                                ),
                              )
                        : const SizedBox.shrink(),
                  );
                },
              );
            },
          ),

        ],
      ),
    );
  }

  String? _tryGetUserId(dynamic user) {
    try { return user.id as String?; } catch (_) {}
    try { return user.uid as String?; } catch (_) {}
    return null;
  }

  String? _tryGetUserEmail(dynamic user) {
    try { return user.email as String?; } catch (_) {}
    return null;
  }
}
