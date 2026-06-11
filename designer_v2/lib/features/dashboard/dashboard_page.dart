import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_scaffold.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_builder.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/comparator_utils.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.filter, super.key});

  final StudiesFilter? filter;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Adapter that mirrors [DashboardState] (loadedStudies + hasMore +
  /// isLoadingMore + loadError) into a [PagingState] consumable by
  /// `infinite_scroll_pagination`'s [PagedSliverList]. The actual fetching
  /// still happens through [DashboardController.loadMore]; this controller
  /// is just a render-state mirror, plus a way for the package to ask us
  /// for the next page.
  ///
  /// We use one big "page" — index 0 holds everything currently loaded —
  /// because [DashboardController] already merges newly-fetched studies
  /// into a single growing list; we don't need the package's per-page
  /// bookkeeping. [PagedSliverList] still recycles rows just fine.
  late final PagingController<int, Study> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Study>(
      // Asking for page 1 means "load next page" — DashboardController
      // ignores the key and uses its own internal offset. We return null
      // when there's no more data to fetch.
      getNextPageKey: (state) => state.hasNextPage ? 1 : null,
      fetchPage: _fetchPage,
    );
    final controller = ref.read(dashboardControllerProvider.notifier);
    runAsync(() => controller.setStudiesFilter(widget.filter));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      final controller = ref.read(dashboardControllerProvider.notifier);
      runAsync(() => controller.setStudiesFilter(widget.filter));
    }
  }

  /// Called by [PagedSliverList] when it needs the next page. We delegate
  /// to [DashboardController.loadMore] and then return the now-loaded slice.
  /// The package only uses our return value to know "did we get more rows"
  /// for its own progress tracking; the canonical data comes from
  /// [_syncPagingState] below.
  Future<List<Study>> _fetchPage(int pageKey) async {
    final controller = ref.read(dashboardControllerProvider.notifier);
    final beforeCount = ref
        .read(dashboardControllerProvider)
        .loadedStudies
        .length;
    await controller.loadMore();
    final after = ref.read(dashboardControllerProvider);
    // Slice of the fresh rows just appended.
    return after.loadedStudies.sublist(beforeCount);
  }

  /// Mirrors current [DashboardState] into the paging controller's value so
  /// [PagedSliverList] renders the canonical list, hasMore flag, and any
  /// load error coming out of [DashboardController].
  void _syncPagingState(DashboardState state) {
    _pagingController.value = PagingState<int, Study>(
      pages: state.loadedStudies.isEmpty ? null : [state.loadedStudies],
      keys: state.loadedStudies.isEmpty ? null : const [0],
      hasNextPage: state.hasMore,
      isLoading: state.isLoadingMore || state.isLoadingInitial,
      error: state.loadError,
    );
  }

  String _getPresetTooltip(String id) {
    if (id == DefaultPresets.myActiveStudies.id) {
      return AppLocalizations.of(context)!.preset_tooltip_my_active_studies;
    } else if (id == DefaultPresets.studiesNeedingAttention.id) {
      return AppLocalizations.of(
        context,
      )!.preset_tooltip_studies_needing_attention;
    } else if (id == DefaultPresets.recentlyCreated.id) {
      return AppLocalizations.of(context)!.preset_tooltip_recently_created;
    } else if (id == DefaultPresets.publicStudies.id) {
      return AppLocalizations.of(context)!.preset_tooltip_public_studies;
    } else if (id == DefaultPresets.draftStudies.id) {
      return AppLocalizations.of(context)!.preset_tooltip_draft_studies;
    }
    return AppLocalizations.of(context)!.preset_custom;
  }

  String _getLocalizedPresetName(String id) {
    if (id == DefaultPresets.myActiveStudies.id) {
      return AppLocalizations.of(context)!.preset_my_active_studies;
    } else if (id == DefaultPresets.studiesNeedingAttention.id) {
      return AppLocalizations.of(context)!.preset_studies_needing_attention;
    } else if (id == DefaultPresets.recentlyCreated.id) {
      return AppLocalizations.of(context)!.preset_recently_created;
    } else if (id == DefaultPresets.publicStudies.id) {
      return AppLocalizations.of(context)!.preset_public_studies;
    } else if (id == DefaultPresets.draftStudies.id) {
      return AppLocalizations.of(context)!.preset_draft_studies;
    }
    return AppLocalizations.of(context)!.preset_custom;
  }

  String _getStudyStatusLabel(StudyStatus status) {
    switch (status) {
      case StudyStatus.draft:
        return AppLocalizations.of(context)!.study_status_draft;
      case StudyStatus.running:
        return AppLocalizations.of(context)!.study_status_running;
      case StudyStatus.closed:
        return AppLocalizations.of(context)!.study_status_closed;
    }
  }

  String _getParticipationLabel(Participation participation) {
    switch (participation) {
      case Participation.open:
        return AppLocalizations.of(context)!.participation_open;
      case Participation.invite:
        return AppLocalizations.of(context)!.participation_invite;
    }
  }

  String _getResultSharingLabel(ResultSharing sharing) {
    switch (sharing) {
      case ResultSharing.public:
        return AppLocalizations.of(context)!.filter_result_sharing_public;
      case ResultSharing.private:
        return AppLocalizations.of(context)!.filter_result_sharing_private;
      case ResultSharing.organization:
        return AppLocalizations.of(context)!.filter_result_sharing_organization;
    }
  }

  String _getFilterChipLabel(FilterCondition condition) {
    final t = AppLocalizations.of(context)!;
    String propertyLabel = condition.property.toString().split('.').last;
    String valueLabel = condition.value.toString();

    switch (condition.property) {
      case StudyProperty.title:
        propertyLabel = t.filter_field_title;
      case StudyProperty.status:
        propertyLabel = t.filter_field_status;
        if (condition.value is String) {
          final status = StudyStatus.values
              .asNameMap()[condition.value as String];
          if (status != null) {
            valueLabel = _getStudyStatusLabel(status);
          }
        }
      case StudyProperty.participation:
        propertyLabel = t.filter_field_participation;
        if (condition.value is String) {
          final participation = Participation.values
              .asNameMap()[condition.value as String];
          if (participation != null) {
            valueLabel = _getParticipationLabel(participation);
          }
        }
      case StudyProperty.resultSharing:
        propertyLabel = t.filter_field_result_sharing;
        if (condition.value is String) {
          final sharing = ResultSharing.values
              .asNameMap()[condition.value as String];
          if (sharing != null) {
            valueLabel = _getResultSharingLabel(sharing);
          }
        }
      case StudyProperty.registryPublished:
        propertyLabel = t.filter_field_registry_published;
        if (condition.value == true) valueLabel = t.filter_bool_yes;
        if (condition.value == false) valueLabel = t.filter_bool_no;
      case StudyProperty.participantCount:
        propertyLabel = t.filter_field_participant_count;
      case StudyProperty.activeSubjectCount:
        propertyLabel = t.filter_field_active_count;
      case StudyProperty.endedCount:
        propertyLabel = t.filter_field_completed_count;
      case StudyProperty.createdAt:
        if (condition.operator == FilterOperator.greaterThanOrEqual ||
            condition.operator == FilterOperator.greaterThan ||
            condition.operator == FilterOperator.after) {
          propertyLabel =
              "${t.filter_field_created_date} (${t.filter_date_from})";
        } else if (condition.operator == FilterOperator.lessThanOrEqual ||
            condition.operator == FilterOperator.lessThan ||
            condition.operator == FilterOperator.before) {
          propertyLabel =
              "${t.filter_field_created_date} (${t.filter_date_to})";
        } else {
          propertyLabel = t.filter_field_created_date;
        }

        DateTime? date;
        if (condition.value is DateTime) {
          date = condition.value as DateTime;
        } else if (condition.value is String) {
          date = DateTime.tryParse(condition.value as String);
        }
        if (date != null) {
          valueLabel = DateFormat.yMMMd().format(date);
        }
      default:
        break;
    }

    if ([
      StudyProperty.participantCount,
      StudyProperty.activeSubjectCount,
      StudyProperty.endedCount,
    ].contains(condition.property)) {
      final opSym = condition.operator.stringSymbol;
      if (opSym != null && opSym.isNotEmpty) {
        return "$propertyLabel $opSym $valueLabel";
      }
    }

    return "$propertyLabel: $valueLabel";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    // Mirror current state into the paging controller every build. Cheap
    // (one PagingState assignment) and keeps the rendered list in lock-step
    // with DashboardController without a second source of truth.
    _syncPagingState(state);

    return DashboardScaffold(
      scaffoldKey: _scaffoldKey,
      endDrawer: const Drawer(width: 400, child: FilterBuilder()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              SizedBox(
                height: 36.0, // Fixed height for alignment
                child: MediaQuery.of(context).size.width < 500
                    ? IconButton.filled(
                        key: const ValueKey('new_study_compact_button'),
                        icon: const Icon(Icons.add),
                        onPressed: controller.onClickNewStudy,
                        tooltip: tr.action_button_new_study,
                      )
                    : PrimaryButton(
                        key: const ValueKey('new_study_button'),
                        text: tr.action_button_new_study,
                        onPressed: controller.onClickNewStudy,
                      ),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Text(
                  state.visibleListTitle,
                  style: theme.textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Preset Dropdown
                      // Unified Filter Button
                      MenuAnchor(
                        builder: (context, controller, child) {
                          final theme = Theme.of(context);
                          final isActive =
                              state.activeFilter != null &&
                              state.activeFilter!.children.isNotEmpty;
                          return Badge(
                            smallSize: 10,
                            isLabelVisible: isActive,
                            child: MediaQuery.of(context).size.width < 600
                                ? IconButton.outlined(
                                    key: const ValueKey('filter_toggle_button'),
                                    onPressed: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                    icon: const Icon(Icons.filter_list),
                                    tooltip: AppLocalizations.of(
                                      context,
                                    )!.filter_button_main,
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          state.activeFilter != null
                                          ? theme.colorScheme.primaryContainer
                                                .withValues(alpha: 0.2)
                                          : null,
                                      side: BorderSide(
                                        color: state.activeFilter != null
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outlineVariant,
                                      ),
                                    ),
                                  )
                                : OutlinedButton.icon(
                                    key: const ValueKey(
                                      'filter_toggle_button_labeled',
                                    ),
                                    onPressed: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                    icon: const Icon(Icons.filter_list),
                                    label: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.filter_button_main,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          state.activeFilter != null
                                          ? theme.colorScheme.primaryContainer
                                                .withValues(alpha: 0.2)
                                          : null,
                                      side: BorderSide(
                                        color: state.activeFilter != null
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outlineVariant,
                                      ),
                                    ),
                                  ),
                          );
                        },
                        menuChildren: [
                          MenuItemButton(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.filter_section_default_presets,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...DefaultPresets.all.map((preset) {
                            final isSelected =
                                state.selectedSavedFilterId == preset.id;
                            final theme = Theme.of(context);
                            return Tooltip(
                              message: _getPresetTooltip(preset.id),
                              child: MenuItemButton(
                                leadingIcon: Icon(
                                  preset.icon ?? Icons.star_border,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                                trailingIcon: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                                onPressed: () {
                                  ref
                                      .read(
                                        dashboardControllerProvider.notifier,
                                      )
                                      .updateFilter(
                                        isSelected
                                            ? FilterGroup()
                                            : preset.root,
                                        presetId: isSelected ? null : preset.id,
                                      );
                                },
                                child: Text(
                                  _getLocalizedPresetName(preset.id),
                                  style: isSelected
                                      ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                          const Divider(),
                          if (state.savedFilters.isNotEmpty) ...[
                            MenuItemButton(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.filter_section_custom_presets,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...state.savedFilters.map((preset) {
                              final isSelected =
                                  state.selectedSavedFilterId == preset.id;
                              final theme = Theme.of(context);
                              return MenuItemButton(
                                leadingIcon: Icon(
                                  preset.icon ?? Icons.person_outline,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                                trailingIcon: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                                onPressed: () {
                                  ref
                                      .read(
                                        dashboardControllerProvider.notifier,
                                      )
                                      .updateFilter(
                                        isSelected
                                            ? FilterGroup()
                                            : preset.root,
                                        presetId: isSelected ? null : preset.id,
                                      );
                                },
                                child: Text(
                                  preset.name,
                                  style: isSelected
                                      ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        )
                                      : null,
                                ),
                              );
                            }),
                            const Divider(),
                          ],

                          MenuItemButton(
                            leadingIcon: const Icon(Icons.tune),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.filter_button_advanced,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState!.openEndDrawer();
                            },
                          ),
                          if (state.activeFilter != null &&
                              state.activeFilter!.children.isNotEmpty) ...[
                            const Divider(),
                            MenuItemButton(
                              leadingIcon: Icon(
                                Icons.clear,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.filter_button_clear,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              onPressed: () {
                                ref
                                    .read(dashboardControllerProvider.notifier)
                                    .updateFilter(FilterGroup());
                              },
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(width: 12),
                      if (MediaQuery.of(context).size.width < 900)
                        IconButton(
                          key: const ValueKey('search_button'),
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: SizedBox(
                                  width: 400,
                                  child: Search(
                                    key: const ValueKey('search_field'),
                                    searchController: state.searchController,
                                    hintText: tr.search,
                                    onQueryChanged: (query) =>
                                        controller.filterStudies(query),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Flexible(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Search(
                              key: const ValueKey('search_field'),
                              searchController: state.searchController,
                              hintText: tr.search,
                              onQueryChanged: (query) =>
                                  controller.filterStudies(query),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (state.activeFilter != null &&
              state.activeFilter!.children.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: state.activeFilter!.children.map((child) {
                if (child is FilterCondition) {
                  return Chip(
                    label: Text(_getFilterChipLabel(child)),
                    onDeleted: () {
                      final newGroup = FilterGroup(
                        logic: state.activeFilter!.logic,
                        children: List.from(state.activeFilter!.children)
                          ..remove(child),
                      );
                      controller.updateFilter(newGroup);
                    },
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ],
          const SizedBox(height: 24.0), // spacing between body elements
          Expanded(
            child: AsyncValueWidget<List<Study>>(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              value: state.displayedStudies,
              data: (visibleStudies) => StudiesTable(
                studies: visibleStudies,
                pinnedStudies: state.pinnedStudiesList.map((s) => s.id),
                dashboardController: ref.watch(
                  dashboardControllerProvider.notifier,
                ),
                pagingController: _pagingController,
                isLoadingMore: state.isLoadingMore,
                hasMore: state.hasMore,
                advancedFilterUnsupported:
                    state.advancedFilterUnsupported,
                loadError: state.loadError,
                onRetry: controller.retry,
                onSelect: controller.onSelectStudy,
                getActions: controller.availableActions,
                emptyWidget:
                    (widget.filter == null ||
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
                              ),
                            )
                    : Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: EmptyBody(
                          icon: Icons.content_paste_search_rounded,
                          title: tr.studies_not_found,
                          description: tr.modify_query,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
