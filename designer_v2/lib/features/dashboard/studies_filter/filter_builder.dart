import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_evaluator.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class FilterBuilder extends ConsumerStatefulWidget {
  const FilterBuilder({Key? key}) : super(key: key);

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
  // Let's try "Between" (Range), "After", "Before".
  FilterOperator _createdOp = FilterOperator
      .greaterThanOrEqual; // Using GTE as default for "After" or start of range

  @override
  void initState() {
    super.initState();
    // Initialize from current active filter if possible
    final activeFilter = ref.read(dashboardControllerProvider).activeFilter;
    if (activeFilter != null) {
      _initFromFilter(activeFilter);
      // Try to find if this filter matches a saved preset
      final saved = ref.read(dashboardControllerProvider).savedFilters;
      for (final s in saved) {
        if (s.root == activeFilter) {
          _loadedPresetId = s.id;
          break;
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
            break;
          case StudyProperty.participation:
            if (child.value is String) {
              _participation = Participation.values.asNameMap()[child.value];
              _participationOp = child.operator;
            }
            break;
          case StudyProperty.resultSharing:
            if (child.value is String) {
              _resultSharing = ResultSharing.values.asNameMap()[child.value];
              _resultSharingOp = child.operator;
            }
            break;
          case StudyProperty.registryPublished:
            _registryPublished = child.value as bool?;
            _registryPublishedOp = child.operator;
            break;
          case StudyProperty.owner:
            _isOwner = child.value as bool?;
            _isOwnerOp = child.operator;
            break;
          case StudyProperty.title:
            _titleController.text = child.value as String? ?? '';
            _titleOp = child.operator;
            break;
          case StudyProperty.participantCount:
            _participantCountController.text = child.value?.toString() ?? '';
            _participantCountOp = child.operator;
            break;
          case StudyProperty.activeSubjectCount:
            _activeSubjectCountController.text = child.value?.toString() ?? '';
            _activeSubjectCountOp = child.operator;
            break;
          case StudyProperty.endedCount:
            _endedCountController.text = child.value?.toString() ?? '';
            _endedCountOp = child.operator;
            break;
          case StudyProperty.createdAt:
            if (child.operator == FilterOperator.greaterThanOrEqual ||
                child.operator == FilterOperator.greaterThan) {
              _createdAfter = child.value as DateTime?;
            } else if (child.operator == FilterOperator.lessThanOrEqual ||
                child.operator == FilterOperator.lessThan) {
              _createdBefore = child.value as DateTime?;
            }
            break;
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

  void _onApply() {
    final group = _buildFilterGroup();
    ref.read(dashboardControllerProvider.notifier).updateFilter(group);
    Navigator.of(context).pop();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Filter preset saved".hardcoded)),
        );
      }
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Preset updated".hardcoded)));
  }

  void _onDeletePreset() {
    if (_loadedPresetId == null) return;
    ref
        .read(dashboardControllerProvider.notifier)
        .deleteFilter(_loadedPresetId!);
    _onResetAll();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Preset deleted".hardcoded)));
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
    final loadedPresetName = _loadedPresetId != null
        ? ref
              .watch(dashboardControllerProvider)
              .savedFilters
              .firstWhere(
                (f) => f.id == _loadedPresetId,
                orElse: () =>
                    SavedFilter(id: '', name: 'Custom', root: FilterGroup()),
              )
              .name
        : "Custom";

    final isDefault = DefaultPresets.all.any((p) => p.id == _loadedPresetId);

    return Container(
      width: 480, // Slightly wider for better spacing
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Sticky Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Text(
                  "Filter Studies".hardcoded,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 12),
                if (_loadedPresetId != null)
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
                const Spacer(),
                MenuAnchor(
                  builder: (context, controller, child) {
                    return IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      icon: const Icon(Icons.more_vert),
                      tooltip: "Preset options".hardcoded,
                    );
                  },
                  menuChildren: [
                    SubmenuButton(
                      menuChildren: [
                        ...DefaultPresets.all.map(
                          (preset) => MenuItemButton(
                            leadingIcon: const Icon(
                              Icons.star_outline,
                              size: 16,
                            ),
                            child: Tooltip(
                              message: _getPresetTooltip(preset.id),
                              child: Text(preset.name),
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
                                  leadingIcon: const Icon(
                                    Icons.perm_identity,
                                    size: 16,
                                  ),
                                  child: Text(preset.name),
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
                      onPressed: (isDefault || _loadedPresetId == null)
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
                      leadingIcon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                      onPressed: (isDefault || _loadedPresetId == null)
                          ? null
                          : _onDeletePreset,
                      child: Text(
                        "Delete preset".hardcoded,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const Divider(),
                    MenuItemButton(
                      leadingIcon: const Icon(Icons.refresh, size: 18),
                      onPressed: _onResetAll,
                      child: Text("Clear / New".hardcoded),
                    ),
                  ],
                ),
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
                  _buildCategory("Basic Info".hardcoded, [
                    _buildTextFilter(
                      "Title".hardcoded,
                      _titleController,
                      _titleOp,
                      (op) => setState(() => _titleOp = op),
                    ),
                    _buildEnumFilter<StudyStatus>(
                      "Status".hardcoded,
                      StudyStatus.values,
                      _status,
                      _statusOp,
                      (v) => setState(() => _status = v),
                      (op) => setState(() => _statusOp = op),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildCategory("Visibility & Role".hardcoded, [
                    _buildEnumFilter<Participation>(
                      "Participation".hardcoded,
                      Participation.values,
                      _participation,
                      _participationOp,
                      (v) => setState(() => _participation = v),
                      (op) => setState(() => _participationOp = op),
                    ),
                    _buildEnumFilter<ResultSharing>(
                      "Result Sharing".hardcoded,
                      ResultSharing.values,
                      _resultSharing,
                      _resultSharingOp,
                      (v) => setState(() => _resultSharing = v),
                      (op) => setState(() => _resultSharingOp = op),
                    ),
                    _buildBoolFilter(
                      "Registry Published".hardcoded,
                      _registryPublished,
                      _registryPublishedOp,
                      (v) => setState(() => _registryPublished = v),
                      (op) => setState(() => _registryPublishedOp = op),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildCategory("Participants".hardcoded, [
                    _buildNumberFilter(
                      "Participant Count".hardcoded,
                      _participantCountController,
                      _participantCountOp,
                      (op) => setState(() => _participantCountOp = op),
                    ),
                    _buildNumberFilter(
                      "Active Count".hardcoded,
                      _activeSubjectCountController,
                      _activeSubjectCountOp,
                      (op) => setState(() => _activeSubjectCountOp = op),
                    ),
                    _buildNumberFilter(
                      "Completed Count".hardcoded,
                      _endedCountController,
                      _endedCountOp,
                      (op) => setState(() => _endedCountOp = op),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildCategory("Dates".hardcoded, [_buildDateRange()]),
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "$matchCount studies match current criteria"
                              .hardcoded,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _onResetAll,
                      icon: const Icon(Icons.restart_alt),
                      label: Text("Reset form".hardcoded),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _onApply,
                      icon: const Icon(Icons.check),
                      label: Text("Apply Filters".hardcoded),
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
    );
  }

  Widget _buildCategory(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAdvancedRow({
    required String title,
    required Widget operatorDropdown,
    required Widget valueInput,
    VoidCallback? onReset,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (onReset != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onReset,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.restart_alt,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed width for operator to align all rows
              SizedBox(width: 130, child: operatorDropdown),
              const SizedBox(width: 8),
              Expanded(child: valueInput),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFilter(
    String title,
    TextEditingController controller,
    FilterOperator op,
    ValueChanged<FilterOperator> onOpChanged,
  ) {
    return _buildAdvancedRow(
      title: title,
      operatorDropdown: _buildOperatorDropdown(
        [
          FilterOperator.contains,
          FilterOperator.equals,
          FilterOperator.startsWith,
          FilterOperator.endsWith,
        ],
        op,
        onOpChanged,
      ),
      valueInput: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.all(12),
          border: OutlineInputBorder(),
        ),
      ),
      onReset: controller.text.isNotEmpty
          ? () => setState(() => controller.clear())
          : null,
    );
  }

  Widget _buildNumberFilter(
    String title,
    TextEditingController controller,
    FilterOperator op,
    ValueChanged<FilterOperator> onOpChanged,
  ) {
    return _buildAdvancedRow(
      title: title,
      operatorDropdown: _buildOperatorDropdown(
        [
          FilterOperator.greaterThanOrEqual,
          FilterOperator.lessThanOrEqual,
          FilterOperator.equals,
          FilterOperator.greaterThan,
          FilterOperator.lessThan,
        ],
        op,
        onOpChanged,
      ),
      valueInput: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.all(12),
          border: OutlineInputBorder(),
          hintText: "0",
        ),
      ),
      onReset: controller.text.isNotEmpty
          ? () => setState(() => controller.clear())
          : null,
    );
  }

  Widget _buildEnumFilter<T>(
    String title,
    List<T> values,
    T? selected,
    FilterOperator op,
    ValueChanged<T?> onChanged,
    ValueChanged<FilterOperator> onOpChanged,
  ) {
    return _buildAdvancedRow(
      title: title,
      operatorDropdown: _buildOperatorDropdown(
        [FilterOperator.equals, FilterOperator.notEquals],
        op,
        onOpChanged,
      ),
      valueInput: DropdownButtonFormField<T>(
        // ignore: deprecated_member_use
        value: selected,
        items: [
          DropdownMenuItem(child: Text("All".hardcoded)),
          ...values.map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e.toString().split('.').last.capitalize()),
            ),
          ),
        ],
        onChanged: onChanged,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(),
        ),
      ),
      onReset: selected != null ? () => onChanged(null) : null,
    );
  }

  Widget _buildBoolFilter(
    String title,
    bool? selected,
    FilterOperator op,
    ValueChanged<bool?> onChanged,
    ValueChanged<FilterOperator> onOpChanged, {
    String trueLabel = "Yes",
    String falseLabel = "No",
  }) {
    return _buildAdvancedRow(
      title: title,
      operatorDropdown: _buildOperatorDropdown(
        [FilterOperator.equals],
        op,
        onOpChanged,
      ),
      valueInput: DropdownButtonFormField<bool>(
        // ignore: deprecated_member_use
        value: selected,
        items: [
          DropdownMenuItem(child: Text("All".hardcoded)),
          DropdownMenuItem(value: true, child: Text(trueLabel.hardcoded)),
          DropdownMenuItem(value: false, child: Text(falseLabel.hardcoded)),
        ],
        onChanged: onChanged,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(),
        ),
      ),
      onReset: selected != null ? () => onChanged(null) : null,
    );
  }

  Widget _buildOperatorDropdown(
    List<FilterOperator> options,
    FilterOperator selected,
    ValueChanged<FilterOperator> onChanged,
  ) {
    return DropdownButtonFormField<FilterOperator>(
      // ignore: deprecated_member_use
      value: selected,
      items: options
          .map(
            (op) =>
                DropdownMenuItem(value: op, child: Text(op.name.capitalize())),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateRange() {
    final hasValue = _createdAfter != null || _createdBefore != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Created Date".hardcoded,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (hasValue) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => setState(() {
                    _createdAfter = null;
                    _createdBefore = null;
                  }),
                  child: Icon(
                    Icons.restart_alt,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _createdAfter ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _createdAfter = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "From",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Text(_createdAfter?.toString().split(' ')[0] ?? ''),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _createdBefore ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _createdBefore = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "To",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Text(_createdBefore?.toString().split(' ')[0] ?? ''),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
