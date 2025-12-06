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

class FilterBuilder extends ConsumerStatefulWidget {
  const FilterBuilder({super.key});

  @override
  ConsumerState<FilterBuilder> createState() => _FilterBuilderState();
}

class _FilterBuilderState extends ConsumerState<FilterBuilder> {
  // State for filters
  String? _loadedPresetId; // Track currently loaded custom preset

  StudyStatus? _status;
  FilterOperator _statusOp = FilterOperator.equals;

  Participation? _participation;
  FilterOperator _participationOp = FilterOperator.equals;

  ResultSharing? _resultSharing;
  FilterOperator _resultSharingOp = FilterOperator.equals;

  bool? _registryPublished;
  FilterOperator _registryPublishedOp = FilterOperator.equals;

  bool? _isOwner;
  FilterOperator _isOwnerOp = FilterOperator.equals;

  // Text/Number inputs
  final TextEditingController _titleController = TextEditingController();
  FilterOperator _titleOp = FilterOperator.contains;

  final TextEditingController _participantCountController =
      TextEditingController();
  FilterOperator _participantCountOp = FilterOperator.greaterThanOrEqual;

  final TextEditingController _activeSubjectCountController =
      TextEditingController();
  FilterOperator _activeSubjectCountOp = FilterOperator.greaterThanOrEqual;

  final TextEditingController _endedCountController = TextEditingController();
  FilterOperator _endedCountOp = FilterOperator.greaterThanOrEqual;

  // Date inputs
  DateTime? _createdAfter;
  DateTime? _createdBefore;
  // We'll treat date range as a special case or use "Between" logic if we want to be strict,
  // but for now let's keep the range picker as it's very intuitive,
  // OR we can add an operator selector for "After", "Before", "Between".
  // Let's try "Between" (Range),  FilterOperator _createdOp = FilterOperator
  // .greaterThanOrEqual; // Using GTE as default for "After" or start of range

  final Set<String> _expandedFields = {};

  @override
  void initState() {
    super.initState();
    // Initialize from current active filter if possible
    final state = ref.read(dashboardControllerProvider);
    final activeFilter = state.activeFilter;
    if (activeFilter != null) {
      _initFromFilter(activeFilter);
      // Trust the ID from the state if available
      if (state.selectedSavedFilterId != null) {
        _loadedPresetId = state.selectedSavedFilterId;
      } else {
        // Try to find if this filter matches a saved preset
        final saved = state.savedFilters;
        for (final s in saved) {
          if (s.root == activeFilter) {
            _loadedPresetId = s.id;
            break;
          }
        }
      }
    }
  }

  void _initFromFilter(FilterGroup group) {
    _onResetAll(
      resetPresetId: false,
    ); // Clear current state first but keep preset ID if needed (logic handled outside)

    // This is a simplified reconstruction. It assumes the structure created by _buildFilterGroup.
    // If the group is complex (nested ORs etc), this might not fully populate the UI,
    // but for the current scope where we only build AND groups of specific conditions, it works.

    for (final child in group.children) {
      if (child is FilterCondition) {
        switch (child.property) {
          case StudyProperty.status:
            if (child.value is String) {
              _status = StudyStatus.values.asNameMap()[child.value];
              _statusOp = child.operator;
            }
          case StudyProperty.participation:
            if (child.value is String) {
              _participation = Participation.values.asNameMap()[child.value];
              _participationOp = child.operator;
            }
          case StudyProperty.resultSharing:
            if (child.value is String) {
              _resultSharing = ResultSharing.values.asNameMap()[child.value];
              _resultSharingOp = child.operator;
            }
          case StudyProperty.registryPublished:
            _registryPublished = child.value as bool?;
            _registryPublishedOp = child.operator;
          case StudyProperty.owner:
            _isOwner = child.value as bool?;
            _isOwnerOp = child.operator;
          case StudyProperty.title:
            _titleController.text = child.value as String? ?? '';
            _titleOp = child.operator;
          case StudyProperty.participantCount:
            _participantCountController.text = child.value?.toString() ?? '';
            _participantCountOp = child.operator;
          case StudyProperty.activeSubjectCount:
            _activeSubjectCountController.text = child.value?.toString() ?? '';
            _activeSubjectCountOp = child.operator;
          case StudyProperty.endedCount:
            _endedCountController.text = child.value?.toString() ?? '';
            _endedCountOp = child.operator;
          case StudyProperty.createdAt:
            if (child.operator == FilterOperator.greaterThanOrEqual ||
                child.operator == FilterOperator.greaterThan) {
              _createdAfter = child.value as DateTime?;
            } else if (child.operator == FilterOperator.lessThanOrEqual ||
                child.operator == FilterOperator.lessThan) {
              _createdBefore = child.value as DateTime?;
            }
          default:
            break;
        }
      }
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

  FilterGroup _buildFilterGroup() {
    final List<FilterCondition> conditions = [];

    // Enums & Bools
    if (_status != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.status,
          operator: _statusOp,
          value: _status!.name,
        ),
      );
    }
    if (_participation != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.participation,
          operator: _participationOp,
          value: _participation!.name,
        ),
      );
    }
    if (_resultSharing != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.resultSharing,
          operator: _resultSharingOp,
          value: _resultSharing!.name,
        ),
      );
    }
    if (_registryPublished != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.registryPublished,
          operator: _registryPublishedOp,
          value: _registryPublished,
        ),
      );
    }
    if (_isOwner != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.owner,
          operator: _isOwnerOp,
          value: _isOwner,
        ),
      );
    }

    // Text
    if (_titleController.text.isNotEmpty) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.title,
          operator: _titleOp,
          value: _titleController.text,
        ),
      );
    }

    // Numbers
    if (_participantCountController.text.isNotEmpty) {
      final val = int.tryParse(_participantCountController.text);
      if (val != null) {
        conditions.add(
          FilterCondition(
            property: StudyProperty.participantCount,
            operator: _participantCountOp,
            value: val,
          ),
        );
      }
    }
    if (_activeSubjectCountController.text.isNotEmpty) {
      final val = int.tryParse(_activeSubjectCountController.text);
      if (val != null) {
        conditions.add(
          FilterCondition(
            property: StudyProperty.activeSubjectCount,
            operator: _activeSubjectCountOp,
            value: val,
          ),
        );
      }
    }
    if (_endedCountController.text.isNotEmpty) {
      final val = int.tryParse(_endedCountController.text);
      if (val != null) {
        conditions.add(
          FilterCondition(
            property: StudyProperty.endedCount,
            operator: _endedCountOp,
            value: val,
          ),
        );
      }
    }

    // Dates
    if (_createdAfter != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.createdAt,
          operator: FilterOperator.greaterThanOrEqual,
          value: _createdAfter,
        ),
      );
    }
    if (_createdBefore != null) {
      conditions.add(
        FilterCondition(
          property: StudyProperty.createdAt,
          operator: FilterOperator.lessThanOrEqual,
          value: _createdBefore,
        ),
      );
    }

    return FilterGroup(children: conditions);
  }

  int _calculateMatchCount() {
    final filter = _buildFilterGroup();
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
    final group = _buildFilterGroup();
    ref.read(dashboardControllerProvider.notifier).updateFilter(group);
  }

  void _onResetAll({bool resetPresetId = true}) {
    setState(() {
      if (resetPresetId) _loadedPresetId = null;
      _status = null;
      _statusOp = FilterOperator.equals;
      _participation = null;
      _participationOp = FilterOperator.equals;
      _resultSharing = null;
      _resultSharingOp = FilterOperator.equals;
      _registryPublished = null;
      _registryPublishedOp = FilterOperator.equals;
      _isOwner = null;
      _isOwnerOp = FilterOperator.equals;
      _titleController.clear();
      _titleOp = FilterOperator.contains;
      _participantCountController.clear();
      _participantCountOp = FilterOperator.greaterThanOrEqual;
      _activeSubjectCountController.clear();
      _activeSubjectCountOp = FilterOperator.greaterThanOrEqual;
      _endedCountController.clear();
      _endedCountOp = FilterOperator.greaterThanOrEqual;
      _createdAfter = null;
      _createdBefore = null;
      _expandedFields.clear();
    });
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
      final filter = SavedFilter(
        id: newId,
        name: name,
        root: _buildFilterGroup(),
      );
      ref.read(dashboardControllerProvider.notifier).saveFilter(filter);
      setState(() => _loadedPresetId = newId);
    }
  }

  void _onUpdatePreset() {
    if (_loadedPresetId == null) return;
    final savedFilters = ref.read(dashboardControllerProvider).savedFilters;
    final existingIndex = savedFilters.indexWhere(
      (f) => f.id == _loadedPresetId,
    );
    if (existingIndex == -1) return;

    final existing = savedFilters[existingIndex];
    final updated = SavedFilter(
      id: existing.id,
      name: existing.name,
      root: _buildFilterGroup(),
      sortColumn: existing.sortColumn,
      sortAscending: existing.sortAscending,
      isDefault: existing.isDefault,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    // We need a method to update, for now saveFilter overwrites if ID exists?
    // Wait, saveFilter in DashboardController likely adds. Check logic.
    // Assuming saveFilter checks for existence or we need an update method.
    // DashboardController.saveFilter implementation: "state = state.copyWith(savedFilters: [...state.savedFilters, filter]);" usually.
    // I should check DashboardController.
    // If it just appends, I need to remove old first.
    ref.read(dashboardControllerProvider.notifier).deleteFilter(existing.id);
    ref.read(dashboardControllerProvider.notifier).saveFilter(updated);
  }

  void _onDeletePreset() {
    if (_loadedPresetId == null) return;
    ref
        .read(dashboardControllerProvider.notifier)
        .deleteFilter(_loadedPresetId!);
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
    final matchCount = _calculateMatchCount();

    SavedFilter? loadedPreset;
    if (_loadedPresetId != null) {
      try {
        loadedPreset = DefaultPresets.all.firstWhere(
          (p) => p.id == _loadedPresetId,
        );
      } catch (_) {
        try {
          loadedPreset = ref
              .watch(dashboardControllerProvider)
              .savedFilters
              .firstWhere((f) => f.id == _loadedPresetId);
        } catch (_) {
          // Preset ID not found (deleted?)
        }
      }
    }

    final loadedPresetName = loadedPreset?.name ?? "Custom";
    final isDefault = DefaultPresets.all.any((p) => p.id == _loadedPresetId);

    final currentGroup = _buildFilterGroup();
    final hasChanges =
        loadedPreset != null &&
        !_areFiltersEqual(loadedPreset.root, currentGroup);

    // Auto-apply on close
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Apply filters when the drawer is closing
        if (didPop) {
          // Update synchronously to ensure the provider is updated before widget disposal
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
                                    color: _loadedPresetId == preset.id
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      _loadedPresetId == preset.id
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
                                        fontWeight: _loadedPresetId == preset.id
                                            ? FontWeight.bold
                                            : null,
                                        color: _loadedPresetId == preset.id
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : null,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    _initFromFilter(preset.root);
                                    setState(() {
                                      _loadedPresetId = preset.id;
                                    });
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
                                          color: _loadedPresetId == preset.id
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : null,
                                        ),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                _loadedPresetId == preset.id
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
                                                _loadedPresetId == preset.id
                                                ? FontWeight.bold
                                                : null,
                                            color: _loadedPresetId == preset.id
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                        onPressed: () {
                                          _initFromFilter(preset.root);
                                          setState(() {
                                            _loadedPresetId = preset.id;
                                          });
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
                                    _loadedPresetId == null ||
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
                              color: (isDefault || _loadedPresetId == null)
                                  ? null
                                  : Colors.red,
                              size: 18,
                            ),
                            onPressed: (isDefault || _loadedPresetId == null)
                                ? null
                                : _onDeletePreset,
                            child: Text(
                              "Delete preset".hardcoded,
                              style: TextStyle(
                                color: (isDefault || _loadedPresetId == null)
                                    ? null
                                    : Colors.red,
                              ),
                            ),
                          ),
                          const Divider(),
                          MenuItemButton(
                            leadingIcon: Icon(
                              Icons.restart_alt,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: _onResetAll,
                            child: Text(
                              "Clear all".hardcoded,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_loadedPresetId != null) ...[
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
                          op: _titleOp,
                          onOpChanged: (op) => setState(() => _titleOp = op),
                          isExpanded: _expandedFields.contains(
                            "Title".hardcoded,
                          ),
                          onExpansionChanged: (v) => setState(() {
                            if (v) {
                              _expandedFields.add("Title".hardcoded);
                            } else {
                              _expandedFields.remove("Title".hardcoded);
                            }
                          }),
                        ),
                        EnumFilter<StudyStatus>(
                          title: "Status".hardcoded,
                          values: StudyStatus.values,
                          selected: _status,
                          op: _statusOp,
                          onChanged: (v) => setState(() => _status = v),
                          onOpChanged: (op) => setState(() => _statusOp = op),
                          isExpanded: _expandedFields.contains(
                            "Status".hardcoded,
                          ),
                          onExpansionChanged: (v) => setState(() {
                            if (v) {
                              _expandedFields.add("Status".hardcoded);
                            } else {
                              _expandedFields.remove("Status".hardcoded);
                            }
                          }),
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
                          selected: _participation,
                          op: _participationOp,
                          onChanged: (v) => setState(() => _participation = v),
                          onOpChanged: (op) =>
                              setState(() => _participationOp = op),
                          isExpanded: _expandedFields.contains(
                            "Participation".hardcoded,
                          ),
                          onExpansionChanged: (v) => setState(() {
                            if (v) {
                              _expandedFields.add("Participation".hardcoded);
                            } else {
                              _expandedFields.remove("Participation".hardcoded);
                            }
                          }),
                        ),
                        EnumFilter<ResultSharing>(
                          title: "Result Sharing".hardcoded,
                          values: ResultSharing.values,
                          selected: _resultSharing,
                          op: _resultSharingOp,
                          onChanged: (v) => setState(() => _resultSharing = v),
                          onOpChanged: (op) =>
                              setState(() => _resultSharingOp = op),
                          isExpanded: _expandedFields.contains(
                            "Result Sharing".hardcoded,
                          ),
                          onExpansionChanged: (v) => setState(() {
                            if (v) {
                              _expandedFields.add("Result Sharing".hardcoded);
                            } else {
                              _expandedFields.remove(
                                "Result Sharing".hardcoded,
                              );
                            }
                          }),
                        ),
                        BoolFilter(
                          title: "Registry Published".hardcoded,
                          selected: _registryPublished,
                          op: _registryPublishedOp,
                          onChanged: (v) =>
                              setState(() => _registryPublished = v),
                          onOpChanged: (op) =>
                              setState(() => _registryPublishedOp = op),
                          isExpanded: _expandedFields.contains(
                            "Registry Published".hardcoded,
                          ),
                          onExpansionChanged: (v) => setState(() {
                            if (v) {
                              _expandedFields.add(
                                "Registry Published".hardcoded,
                              );
                            } else {
                              _expandedFields.remove(
                                "Registry Published".hardcoded,
                              );
                            }
                          }),
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
                          op: _participantCountOp,
                          onOpChanged: (op) =>
                              setState(() => _participantCountOp = op),
                          isExpanded: _expandedFields.contains(
                            "Participant Count".hardcoded,
                          ),
                          onExpansionChanged: (v) => setState(() {
                            if (v) {
                              _expandedFields.add(
                                "Participant Count".hardcoded,
                              );
                            } else {
                              _expandedFields.remove(
                                "Participant Count".hardcoded,
                              );
                            }
                          }),
                        ),
                        NumberFilter(
                          title: "Active Count".hardcoded,
                          controller: _activeSubjectCountController,
                          op: _activeSubjectCountOp,
                          onOpChanged: (op) =>
                              setState(() => _activeSubjectCountOp = op),
                          isExpanded: _expandedFields.contains(
                            "Active Count".hardcoded,
                          ),
                          onExpansionChanged: (v) => setState(() {
                            if (v) {
                              _expandedFields.add("Active Count".hardcoded);
                            } else {
                              _expandedFields.remove("Active Count".hardcoded);
                            }
                          }),
                        ),
                        NumberFilter(
                          title: "Completed Count".hardcoded,
                          controller: _endedCountController,
                          op: _endedCountOp,
                          onOpChanged: (op) =>
                              setState(() => _endedCountOp = op),
                          isExpanded: _expandedFields.contains(
                            "Completed Count".hardcoded,
                          ),
                          onExpansionChanged: (v) => setState(() {
                            if (v) {
                              _expandedFields.add("Completed Count".hardcoded);
                            } else {
                              _expandedFields.remove(
                                "Completed Count".hardcoded,
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilterCategory(
                      title: "Dates".hardcoded,
                      children: [
                        DateRangeFilter(
                          start: _createdAfter,
                          end: _createdBefore,
                          onStartChanged: (v) =>
                              setState(() => _createdAfter = v),
                          onEndChanged: (v) =>
                              setState(() => _createdBefore = v),
                          isExpanded: _expandedFields.contains(
                            "Created Date".hardcoded,
                          ),
                          onExpansionChanged: (v) => setState(() {
                            if (v) {
                              _expandedFields.add("Created Date".hardcoded);
                            } else {
                              _expandedFields.remove("Created Date".hardcoded);
                            }
                          }),
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
