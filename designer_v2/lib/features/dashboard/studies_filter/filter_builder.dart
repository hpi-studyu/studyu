import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_evaluator.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_category.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/text_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/number_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/enum_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/bool_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/date_range_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_draft_controller.dart';

class FilterBuilder extends ConsumerStatefulWidget {
  const FilterBuilder({super.key});

  @override
  ConsumerState<FilterBuilder> createState() => _FilterBuilderState();
}

class _FilterBuilderState extends ConsumerState<FilterBuilder> {
  // Text/Number inputs need controllers for the UI, but we sync them with state
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _participantCountController =
      TextEditingController();
  final TextEditingController _activeSubjectCountController =
      TextEditingController();
  final TextEditingController _endedCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize from current active filter if possible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromProvider();
    });
  }

  void _initFromProvider() {
    final state = ref.read(dashboardControllerProvider);
    final activeFilter = state.activeFilter;
    final controller = ref.read(filterDraftControllerProvider.notifier);

    if (activeFilter != null) {
      String? presetId;
      if (state.selectedSavedFilterId != null) {
        presetId = state.selectedSavedFilterId;
      } else {
        // Try to find if this filter matches a saved preset
        final saved = state.savedFilters;
        for (final s in saved) {
          if (s.root == activeFilter) {
            presetId = s.id;
            break;
          }
        }
      }
      controller.initFromFilter(activeFilter, presetId: presetId);
      _syncControllers(ref.read(filterDraftControllerProvider));
    }

    // Attach listeners to update state on text change
    _titleController.addListener(() {
      ref
          .read(filterDraftControllerProvider.notifier)
          .updateTitle(_titleController.text);
    });
    _participantCountController.addListener(() {
      ref
          .read(filterDraftControllerProvider.notifier)
          .updateParticipantCount(_participantCountController.text);
    });
    _activeSubjectCountController.addListener(() {
      ref
          .read(filterDraftControllerProvider.notifier)
          .updateActiveSubjectCount(_activeSubjectCountController.text);
    });
    _endedCountController.addListener(() {
      ref
          .read(filterDraftControllerProvider.notifier)
          .updateEndedCount(_endedCountController.text);
    });
  }

  void _syncControllers(FilterDraft draft) {
    if (_titleController.text != draft.title) {
      _titleController.text = draft.title;
    }
    if (_participantCountController.text != draft.participantCount) {
      _participantCountController.text = draft.participantCount;
    }
    if (_activeSubjectCountController.text != draft.activeSubjectCount) {
      _activeSubjectCountController.text = draft.activeSubjectCount;
    }
    if (_endedCountController.text != draft.endedCount) {
      _endedCountController.text = draft.endedCount;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _participantCountController.dispose();
    _activeSubjectCountController.dispose();
    _endedCountController.dispose();
    super.dispose();
  }

  int _calculateMatchCount(FilterGroup filter) {
    final studies = ref.read(dashboardControllerProvider).studies.value ?? [];
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser == null) return 0;
    return studies
        .where((s) => FilterEvaluator.evaluate(filter, s, supabaseUser))
        .length;
  }

  bool _areFiltersEqual(FilterElement? a, FilterElement? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.runtimeType != b.runtimeType) return false;

    if (a is FilterCondition && b is FilterCondition) {
      return a.property == b.property &&
          a.operator == b.operator &&
          a.value == b.value;
    } else if (a is FilterGroup && b is FilterGroup) {
      if (a.logic != b.logic) return false;
      if (a.children.length != b.children.length) return false;
      for (int i = 0; i < a.children.length; i++) {
        if (!_areFiltersEqual(a.children[i], b.children[i])) return false;
      }
      return true;
    }
    return false;
  }

  void _applyFilter() {
    final group = ref.read(filterDraftControllerProvider).toFilterGroup;
    ref.read(dashboardControllerProvider.notifier).updateFilter(group);
  }

  void _onResetAll() {
    final controller = ref.read(filterDraftControllerProvider.notifier);
    controller.resetAll();
    _syncControllers(ref.read(filterDraftControllerProvider));
  }

  Future<void> _onSavePreset() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Save Filter Preset".hardcoded),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Preset Name".hardcoded),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel".hardcoded),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text("Save".hardcoded),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final newId = const Uuid().v4();
      final filterDraft = ref.read(filterDraftControllerProvider);
      final filter = SavedFilter(
        id: newId,
        name: name,
        root: filterDraft.toFilterGroup,
      );
      ref.read(dashboardControllerProvider.notifier).saveFilter(filter);

      ref
          .read(filterDraftControllerProvider.notifier)
          .updateLoadedPreset(newId);
    }
  }

  void _onUpdatePreset() {
    final filterDraft = ref.read(filterDraftControllerProvider);
    if (filterDraft.loadedPresetId == null) return;

    final savedFilters = ref.read(dashboardControllerProvider).savedFilters;
    final existingIndex = savedFilters.indexWhere(
      (f) => f.id == filterDraft.loadedPresetId,
    );
    if (existingIndex == -1) return;

    final existing = savedFilters[existingIndex];
    final updated = SavedFilter(
      id: existing.id,
      name: existing.name,
      root: filterDraft.toFilterGroup,
      sortColumn: existing.sortColumn,
      sortAscending: existing.sortAscending,
      isDefault: existing.isDefault,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    ref.read(dashboardControllerProvider.notifier).deleteFilter(existing.id);
    ref.read(dashboardControllerProvider.notifier).saveFilter(updated);
  }

  void _onDeletePreset() {
    final loadedId = ref.read(filterDraftControllerProvider).loadedPresetId;
    if (loadedId == null) return;
    ref.read(dashboardControllerProvider.notifier).deleteFilter(loadedId);
    _onResetAll();
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
    final draft = ref.watch(filterDraftControllerProvider);
    final controller = ref.watch(filterDraftControllerProvider.notifier);
    final matchCount = _calculateMatchCount(draft.toFilterGroup);

    SavedFilter? loadedPreset;
    if (draft.loadedPresetId != null) {
      try {
        loadedPreset = DefaultPresets.all.firstWhere(
          (p) => p.id == draft.loadedPresetId,
        );
      } catch (_) {
        try {
          loadedPreset = ref
              .watch(dashboardControllerProvider)
              .savedFilters
              .firstWhere((f) => f.id == draft.loadedPresetId);
        } catch (_) {
          // Preset ID not found (deleted?)
        }
      }
    }

    final loadedPresetName = loadedPreset?.name ?? "Custom";
    final isDefault = DefaultPresets.all.any(
      (p) => p.id == draft.loadedPresetId,
    );

    final currentGroup = draft.toFilterGroup;
    final hasChanges =
        loadedPreset != null &&
        !_areFiltersEqual(loadedPreset.root, currentGroup);

    // Auto-apply on close
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Apply filters when the drawer is closing
        if (didPop) {
          // Update synchronously to ensure the provider is updated before widget disposal
          // Note: _applyFilter reads the provider, which is fine.
          _applyFilter();
        }
      },

      child: Container(
        width: 480, // Slightly wider for better spacing
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Sticky Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Filter Studies".hardcoded,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Spacer(),
                      MenuAnchor(
                        builder: (context, controller, child) {
                          return OutlinedButton(
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            child: Text("Manage Presets".hardcoded),
                          );
                        },
                        menuChildren: [
                          SubmenuButton(
                            menuChildren: [
                              ...DefaultPresets.all.map(
                                (preset) => MenuItemButton(
                                  leadingIcon: Icon(
                                    Icons.star_outline,
                                    size: 16,
                                    color: draft.loadedPresetId == preset.id
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      draft.loadedPresetId == preset.id
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                                .withValues(alpha: 0.2)
                                          : null,
                                    ),
                                  ),
                                  child: Tooltip(
                                    message: _getPresetTooltip(preset.id),
                                    child: Text(
                                      preset.name,
                                      style: TextStyle(
                                        fontWeight:
                                            draft.loadedPresetId == preset.id
                                            ? FontWeight.bold
                                            : null,
                                        color: draft.loadedPresetId == preset.id
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : null,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    controller.initFromFilter(
                                      preset.root,
                                      presetId: preset.id,
                                    );
                                    _syncControllers(
                                      ref.read(filterDraftControllerProvider),
                                    );
                                  },
                                ),
                              ),
                              const Divider(),
                              if (ref
                                  .read(dashboardControllerProvider)
                                  .savedFilters
                                  .isNotEmpty)
                                ...ref
                                    .read(dashboardControllerProvider)
                                    .savedFilters
                                    .map(
                                      (preset) => MenuItemButton(
                                        leadingIcon: Icon(
                                          Icons.perm_identity,
                                          size: 16,
                                          color:
                                              draft.loadedPresetId == preset.id
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : null,
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                draft.loadedPresetId ==
                                                        preset.id
                                                    ? Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer
                                                          .withValues(
                                                            alpha: 0.2,
                                                          )
                                                    : null,
                                              ),
                                        ),
                                        child: Text(
                                          preset.name,
                                          style: TextStyle(
                                            fontWeight:
                                                draft.loadedPresetId ==
                                                    preset.id
                                                ? FontWeight.bold
                                                : null,
                                            color:
                                                draft.loadedPresetId ==
                                                    preset.id
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                        onPressed: () {
                                          controller.initFromFilter(
                                            preset.root,
                                            presetId: preset.id,
                                          );
                                          _syncControllers(
                                            ref.read(
                                              filterDraftControllerProvider,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                              else
                                MenuItemButton(
                                  child: Text("No custom presets".hardcoded),
                                ),
                            ],
                            child: Text("Load Preset".hardcoded),
                          ),
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.save_as, size: 18),
                            onPressed:
                                (isDefault ||
                                    draft.loadedPresetId == null ||
                                    !hasChanges)
                                ? null
                                : _onUpdatePreset,
                            child: Text("Save changes".hardcoded),
                          ),
                          MenuItemButton(
                            leadingIcon: const Icon(Icons.save, size: 18),
                            onPressed: _onSavePreset,
                            child: Text("Save as new".hardcoded),
                          ),
                          MenuItemButton(
                            leadingIcon: Icon(
                              Icons.delete_outline,
                              color: (isDefault || draft.loadedPresetId == null)
                                  ? null
                                  : Colors.red,
                              size: 18,
                            ),
                            onPressed:
                                (isDefault || draft.loadedPresetId == null)
                                ? null
                                : _onDeletePreset,
                            child: Text(
                              "Delete preset".hardcoded,
                              style: TextStyle(
                                color:
                                    (isDefault || draft.loadedPresetId == null)
                                    ? null
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (draft.loadedPresetId != null) ...[
                    const SizedBox(height: 12),
                    Tooltip(
                      message: "Currently loaded preset".hardcoded,
                      child: Chip(
                        label: Text(loadedPresetName),
                        onDeleted: _onResetAll,
                        deleteIconColor: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                        side: BorderSide.none,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilterCategory(
                      title: "Basic Info".hardcoded,
                      children: [
                        TextFilter(
                          title: "Title".hardcoded,
                          controller: _titleController,
                          op: draft.titleOp,
                          onOpChanged: controller.updateTitleOp,
                          isExpanded: draft.expandedFields.contains(
                            "Title".hardcoded,
                          ),
                          onExpansionChanged: (v) =>
                              controller.toggleExpansion("Title".hardcoded, v),
                        ),
                        EnumFilter<StudyStatus>(
                          title: "Status".hardcoded,
                          values: StudyStatus.values,
                          selected: draft.status,
                          op: draft.statusOp,
                          onChanged: controller.updateStatus,
                          onOpChanged: controller.updateStatusOp,
                          isExpanded: draft.expandedFields.contains(
                            "Status".hardcoded,
                          ),
                          onExpansionChanged: (v) =>
                              controller.toggleExpansion("Status".hardcoded, v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilterCategory(
                      title: "Visibility & Role".hardcoded,
                      children: [
                        EnumFilter<Participation>(
                          title: "Participation".hardcoded,
                          values: Participation.values,
                          selected: draft.participation,
                          op: draft.participationOp,
                          onChanged: controller.updateParticipation,
                          onOpChanged: controller.updateParticipationOp,
                          isExpanded: draft.expandedFields.contains(
                            "Participation".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Participation".hardcoded,
                            v,
                          ),
                        ),
                        EnumFilter<ResultSharing>(
                          title: "Result Sharing".hardcoded,
                          values: ResultSharing.values,
                          selected: draft.resultSharing,
                          op: draft.resultSharingOp,
                          onChanged: controller.updateResultSharing,
                          onOpChanged: controller.updateResultSharingOp,
                          isExpanded: draft.expandedFields.contains(
                            "Result Sharing".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Result Sharing".hardcoded,
                            v,
                          ),
                        ),
                        BoolFilter(
                          title: "Registry Published".hardcoded,
                          selected: draft.registryPublished,
                          op: draft.registryPublishedOp,
                          onChanged: controller.updateRegistryPublished,
                          onOpChanged: controller.updateRegistryPublishedOp,
                          isExpanded: draft.expandedFields.contains(
                            "Registry Published".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Registry Published".hardcoded,
                            v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilterCategory(
                      title: "Participants".hardcoded,
                      children: [
                        NumberFilter(
                          title: "Participant Count".hardcoded,
                          controller: _participantCountController,
                          op: draft.participantCountOp,
                          onOpChanged: controller.updateParticipantCountOp,
                          isExpanded: draft.expandedFields.contains(
                            "Participant Count".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Participant Count".hardcoded,
                            v,
                          ),
                        ),
                        NumberFilter(
                          title: "Active Count".hardcoded,
                          controller: _activeSubjectCountController,
                          op: draft.activeSubjectCountOp,
                          onOpChanged: controller.updateActiveSubjectCountOp,
                          isExpanded: draft.expandedFields.contains(
                            "Active Count".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Active Count".hardcoded,
                            v,
                          ),
                        ),
                        NumberFilter(
                          title: "Completed Count".hardcoded,
                          controller: _endedCountController,
                          op: draft.endedCountOp,
                          onOpChanged: controller.updateEndedCountOp,
                          isExpanded: draft.expandedFields.contains(
                            "Completed Count".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Completed Count".hardcoded,
                            v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilterCategory(
                      title: "Dates".hardcoded,
                      children: [
                        DateRangeFilter(
                          start: draft.createdAfter,
                          end: draft.createdBefore,
                          onStartChanged: controller.updateCreatedAfter,
                          onEndChanged: controller.updateCreatedBefore,
                          isExpanded: draft.expandedFields.contains(
                            "Created Date".hardcoded,
                          ),
                          onExpansionChanged: (v) => controller.toggleExpansion(
                            "Created Date".hardcoded,
                            v,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            // Sticky Footer
            Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _onResetAll,
                        icon: const Icon(Icons.restart_alt),
                        label: Text("Clear all".hardcoded),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),

                      FilledButton.icon(
                        onPressed: () {
                          _applyFilter();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check),
                        label: Text("Show $matchCount Studies".hardcoded),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
