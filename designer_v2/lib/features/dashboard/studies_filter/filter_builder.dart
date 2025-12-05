import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_evaluator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class FilterBuilder extends ConsumerStatefulWidget {
  const FilterBuilder({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterBuilder> createState() => _FilterBuilderState();
}

class _FilterBuilderState extends ConsumerState<FilterBuilder> {
  // State for filters
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
    }
  }

  void _initFromFilter(FilterGroup group) {
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
            // This is tricky because we map range to two conditions.
            // Simplified: if we find GTE, set createdAfter. If LTE, set createdBefore.
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

    return FilterGroup(logic: FilterLogic.and, children: conditions);
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

  void _onResetAll() {
    setState(() {
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
      final filter = SavedFilter(
        id: const Uuid().v4(),
        name: name,
        root: _buildFilterGroup(),
      );
      ref.read(dashboardControllerProvider.notifier).saveFilter(filter);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Filter preset saved".hardcoded)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchCount = _calculateMatchCount();

    return Container(
      width: 450, // Slightly wider for advanced options
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Filter".hardcoded,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.save_outlined),
                tooltip: "Save as preset".hardcoded,
                onPressed: _onSavePreset,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
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
                  const Divider(height: 32),
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
                    _buildBoolFilter(
                      "Role".hardcoded,
                      _isOwner,
                      _isOwnerOp,
                      (v) => setState(() => _isOwner = v),
                      (op) => setState(() => _isOwnerOp = op),
                      trueLabel: "Owner",
                      falseLabel: "Editor",
                    ),
                  ]),
                  const Divider(height: 32),
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
                  const Divider(height: 32),
                  _buildCategory("Dates".hardcoded, [_buildDateRange()]),
                  const SizedBox(height: 24), // Extra spacing
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
                Text(
                  "$matchCount studies match your criteria".hardcoded,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: _onResetAll,
                child: Text("Reset all".hardcoded),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel".hardcoded),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _onApply,
                child: Text("Apply now".hardcoded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildAdvancedRow({
    required String title,
    required Widget operatorDropdown,
    required Widget valueInput,
    VoidCallback? onReset,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              if (onReset != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onReset,
                  child: Icon(
                    Icons.restart_alt,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
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
        value: selected,
        items: [
          DropdownMenuItem(value: null, child: Text("All".hardcoded)),
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
        value: selected,
        items: [
          DropdownMenuItem(value: null, child: Text("All".hardcoded)),
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
      padding: const EdgeInsets.only(bottom: 24.0),
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
          const SizedBox(height: 4),
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
