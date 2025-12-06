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
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_builder.dart';

import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';

import 'package:studyu_designer_v2/utils/performance.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.filter, super.key});

  final StudiesFilter? filter;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  String _getPresetTooltip(String id) {
    if (id == DefaultPresets.myActiveStudies.id) {
      return "Studies you own that are currently running".hardcoded;
    } else if (id == DefaultPresets.studiesNeedingAttention.id) {
      return "Running studies with low participation".hardcoded;
    } else if (id == DefaultPresets.recentlyCreated.id) {
      return "Studies created in the last 30 days".hardcoded;
    } else if (id == DefaultPresets.publicStudies.id) {
      return "Studies published to the registry or with public results"
          .hardcoded;
    } else if (id == DefaultPresets.draftStudies.id) {
      return "Studies currently in draft mode".hardcoded;
    }
    return "Custom preset".hardcoded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    return DashboardScaffold(
      scaffoldKey: _scaffoldKey,
      endDrawer: const Drawer(width: 400, child: FilterBuilder()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              SizedBox(
                height: 36.0,
                child: PrimaryButton(
                  text: tr.action_button_new_study,
                  onPressed: controller.onClickNewStudy,
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
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                              icon: const Icon(Icons.filter_list),
                              label: Text("Filter".hardcoded),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: state.activeFilter != null
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
                              "Default Presets".hardcoded,
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
                                  preset.name,
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
                                "Custom Presets".hardcoded,
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
                            leadingIcon: Badge(
                              smallSize: 10,
                              isLabelVisible:
                                  state.activeFilter != null &&
                                  state.activeFilter!.children.isNotEmpty,
                              child: const Icon(Icons.tune),
                            ),
                            child: Text("Advanced Filters...".hardcoded),
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
                                "Clear filter".hardcoded,
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

                      const SizedBox(width: 16),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Search(
                          searchController: state.searchController,
                          hintText: tr.search,
                          onQueryChanged: (query) =>
                              controller.filterStudies(query),
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
                    label: Text(
                      "${child.property.toString().split('.').last}: ${child.value}",
                    ),
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
          FutureBuilder<StudyUUser>(
            future: ref.read(userRepositoryProvider).fetchUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AsyncValueWidget<List<Study>>(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  value: state.displayedStudies(
                    snapshot.data!.preferences.pinnedStudies,
                    state.query,
                  ),
                  data: (visibleStudies) => StudiesTable(
                    studies: visibleStudies,
                    pinnedStudies: snapshot.data!.preferences.pinnedStudies,
                    dashboardController: ref.watch(
                      dashboardControllerProvider.notifier,
                    ),
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
}
