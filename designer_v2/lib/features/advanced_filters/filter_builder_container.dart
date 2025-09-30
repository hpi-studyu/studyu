// ignore_for_file: directives_ordering, always_use_package_imports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studyu_designer_v2/features/advanced_filters/created_at_filter.dart';
import './advanced_filters_controller.dart';
import '../../domain/advanced_filters_model.dart';
import './advanced_filters_state.dart'; // <-- for kFieldMeta + types

class FilterBuilderContainer extends ConsumerWidget {
  const FilterBuilderContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(filterBuilderProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter builder', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _GroupView(group: draft.root, depth: 0),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
              onPressed: () {
                // reset the draft (builder UI)
                ref.read(filterBuilderProvider.notifier).reset();
                // also clear any active filter
                ref.read(activeFilterDraftProvider.notifier).state = null;
              },
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Apply'),
              onPressed: () {
                final draft = ref.read(filterBuilderProvider);
                // store as active filter for the Dashboard to consume
                ref.read(activeFilterDraftProvider.notifier).state = draft;
                Navigator.of(context).maybePop();
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
              onPressed: () => ref.read(filterBuilderProvider.notifier).reset(),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Apply'),
              onPressed: () {
                // Wire up in next task (compile to predicate / DTO)
                Navigator.of(context).maybePop();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _GroupView extends ConsumerWidget {
  const _GroupView({required this.group, required this.depth});
  final GroupNode group;
  final int depth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(filterBuilderProvider.notifier);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(left: (depth * 12).toDouble()),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                SegmentedButton<LogicalOp>(
                  segments: const [
                    ButtonSegment(value: LogicalOp.and, label: Text('AND')),
                    ButtonSegment(value: LogicalOp.or, label: Text('OR')),
                  ],
                  selected: {group.op},
                  onSelectionChanged: (s) => ctrl.setGroupOp(group.id, s.first),
                ),
                const SizedBox(width: 8),
                Text('Group', style: theme.textTheme.titleMedium),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'Add condition',
                  icon: const Icon(Icons.note_add),
                  onPressed: () => ctrl.addCondition(group.id),
                ),
                const SizedBox(width: 4),
                IconButton.filledTonal(
                  tooltip: 'Add subgroup',
                  icon: const Icon(Icons.playlist_add),
                  onPressed: () => ctrl.addGroup(group.id),
                ),
                if (depth > 0) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Remove group',
                    icon: const Icon(Icons.delete),
                    onPressed: () => ctrl.removeNode(group.id),
                  ),
                ],
              ],
            ),
            const Divider(height: 20),
            Column(
              children: group.children.map((node) {
                if (node is GroupNode) {
                  return _GroupView(group: node, depth: depth + 1);
                } else if (node is ConditionNode) {
                  return _ConditionRow(node: node, depth: depth + 1);
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
            if (group.children.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'No conditions yet. Add a condition or subgroup.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConditionRow extends ConsumerWidget {
  const _ConditionRow({required this.node, required this.depth});
  final ConditionNode node;
  final int depth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(filterBuilderProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(left: (depth * 12).toDouble(), bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 520; // stack on narrow

          // FIELD DROPDOWN — reset predicate if it’s not valid for new field
          final fieldDropdown = SizedBox(
            width: narrow ? double.infinity : 220,
            child: DropdownButtonFormField<StudyField>(
              value: node.field,
              decoration: const InputDecoration(labelText: 'Field'),
              items: StudyField.values
                  .map((f) => DropdownMenuItem(value: f, child: Text(_labelField(f))))
                  .toList(),
              onChanged: (f) {
                if (f == null) return;

                final allowed = _allowedPredicates(f);
                final newPredicate = allowed.contains(node.predicate)
                    ? node.predicate
                    : allowed.first;

                ctrl.updateCondition(
                  node.id,
                  node.copyWith(
                    field: f,
                    predicate: newPredicate,
                    value: null,
                    value2: null,
                  ),
                );
              },
            ),
          );

          // OPERATOR DROPDOWN — guard value so it’s always valid
          final allowedForCurrent = _allowedPredicates(node.field);
          final safePredicate = allowedForCurrent.contains(node.predicate)
              ? node.predicate
              : allowedForCurrent.first;

          final opDropdown = SizedBox(
            width: narrow ? double.infinity : 200,
            child: DropdownButtonFormField<Predicate>(
              value: safePredicate,
              decoration: const InputDecoration(labelText: 'Operator'),
              items: allowedForCurrent
                  .map((p) => DropdownMenuItem(value: p, child: Text(_labelPredicate(p))))
                  .toList(),
              onChanged: (p) {
                if (p == null) return;
                ctrl.updateCondition(node.id, node.copyWith(predicate: p, value: null, value2: null));
              },
            ),
          );

          // Value editors expand to available width
          final valueEditors = _valueEditors(context, node, ctrl)
              .map((w) => narrow ? w : Expanded(child: w))
              .toList();

          final deleteBtn = IconButton(
            tooltip: 'Remove condition',
            icon: const Icon(Icons.delete),
            onPressed: () => ctrl.removeNode(node.id),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fieldDropdown, const SizedBox(height: 8),
                opDropdown, const SizedBox(height: 8),
                ...valueEditors.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: w,
                    )),
                Align(alignment: Alignment.centerRight, child: deleteBtn),
              ],
            );
          }

          // wide: allow horizontal scroll to avoid overflow edge cases
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  fieldDropdown, const SizedBox(width: 8),
                  opDropdown, const SizedBox(width: 8),
                  ...valueEditors, const SizedBox(width: 8),
                  deleteBtn,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Operator whitelist per field (kept tight so UI stays consistent with type).
  List<Predicate> _allowedPredicates(StudyField field) {
    switch (field) {
      case StudyField.title:
      case StudyField.owner:
        return const [Predicate.equals, Predicate.notEquals, Predicate.contains];

      case StudyField.status:
      case StudyField.resultSharing:
        // enum fields → no "contains"
        return const [Predicate.equals, Predicate.notEquals];

      case StudyField.registryPublished:
        // boolean handled as unary ops
        return const [Predicate.isTrue, Predicate.isFalse];

      case StudyField.participation:
      case StudyField.totalMissedDays:
        return const [
          Predicate.equals,
          Predicate.notEquals,
          Predicate.lessThan,
          Predicate.greaterThan,
          Predicate.between,
        ];

      case StudyField.createdAt:
        return const [
          Predicate.lessThan,
          Predicate.greaterThan,
          Predicate.between,
          Predicate.inLastDays,
        ];
    }
  }

  /// TYPE-AWARE VALUE INPUTS
  List<Widget> _valueEditors(
    BuildContext context,
    ConditionNode node,
    FilterBuilderController ctrl,
  ) {
    // CreatedAt has special UX (presets + range)
    if (node.field == StudyField.createdAt) {
      switch (node.predicate) {
        case Predicate.inLastDays:
          const items = <DropdownMenuItem<CreatedAtPreset>>[
            DropdownMenuItem(value: CreatedAtPreset.any, child: Text('Any time')),
            DropdownMenuItem(value: CreatedAtPreset.last7d, child: Text('Last 7 days')),
            DropdownMenuItem(value: CreatedAtPreset.last30d, child: Text('Last 30 days')),
            DropdownMenuItem(value: CreatedAtPreset.last90d, child: Text('Last 90 days')),
            DropdownMenuItem(value: CreatedAtPreset.last180d, child: Text('Last 180 days')),
            DropdownMenuItem(value: CreatedAtPreset.customRange, child: Text('Custom range…')),
          ];

          final current = node.value is CreatedAtPreset
              ? node.value as CreatedAtPreset
              : CreatedAtPreset.last30d;

          final safeValue =
              items.any((i) => i.value == current) ? current : CreatedAtPreset.last30d;

          return [
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<CreatedAtPreset>(
                value: safeValue,
                items: items,
                decoration: const InputDecoration(labelText: 'Created at'),
                onChanged: (v) async {
                  if (v == null) return;

                  if (v == CreatedAtPreset.customRange) {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      ctrl.updateCondition(
                        node.id,
                        node.copyWith(
                          predicate: Predicate.between,
                          value: DateTime(
                              picked.start.year, picked.start.month, picked.start.day),
                          value2:
                              DateTime(picked.end.year, picked.end.month, picked.end.day),
                        ),
                      );
                      return;
                    }
                  }

                  ctrl.updateCondition(node.id, node.copyWith(value: v, value2: null));
                },
              ),
            ),
          ];

        case Predicate.between:
          final from = node.value is DateTime ? node.value as DateTime : null;
          final to = node.value2 is DateTime ? node.value2 as DateTime : null;

          return [
            _dateField(
              context: context,
              label: 'From',
              initial: from,
              onPicked: (d) => ctrl.updateCondition(node.id, node.copyWith(value: d)),
            ),
            const SizedBox(width: 8),
            _dateField(
              context: context,
              label: 'To',
              initial: to,
              onPicked: (d) => ctrl.updateCondition(node.id, node.copyWith(value2: d)),
            ),
          ];

        case Predicate.lessThan:
        case Predicate.greaterThan:
          final single = node.value is DateTime ? node.value as DateTime : null;
          return [
            _dateField(
              context: context,
              label: 'Date',
              initial: single,
              onPicked: (d) => ctrl.updateCondition(node.id, node.copyWith(value: d)),
            ),
          ];

        default:
          return _fallbackText(node, ctrl);
      }
    }

    // All other fields → drive by kFieldMeta
    // All other fields → drive by kFieldMeta
    final fieldMeta = kFieldMeta[node.field];
    if (fieldMeta == null) {
      // If you forgot to register this StudyField in kFieldMeta,
      // we just show a plain text input as a safe fallback.
      return _fallbackText(node, ctrl);
    }

    switch (fieldMeta.type) {
      case FilterPropType.boolean:
        // handled via isTrue / isFalse → no value editors
        return const [];

      case FilterPropType.enumeration:
        final options = fieldMeta.options;
        final current = (node.value is String) ? node.value as String : null;
        final valid = options.any((o) => o.key == current);
        final safeValue = valid ? current : null;

        return [
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              value: safeValue,
              decoration: InputDecoration(labelText: fieldMeta.label),
              items: options
                  .map((o) => DropdownMenuItem<String>(
                        value: o.key,
                        child: Text(o.label),
                      ))
                  .toList(),
              onChanged: (k) =>
                  ctrl.updateCondition(node.id, node.copyWith(value: k)),
            ),
          ),
        ];

      case FilterPropType.number:
        if (node.predicate == Predicate.between) {
          final v1 = node.value?.toString() ?? '';
          final v2 = node.value2?.toString() ?? '';
          return [
            SizedBox(
              width: 160,
              child: TextFormField(
                initialValue: v1,
                decoration: const InputDecoration(labelText: 'From'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => ctrl.updateCondition(
                  node.id,
                  node.copyWith(value: num.tryParse(v) ?? v),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 160,
              child: TextFormField(
                initialValue: v2,
                decoration: const InputDecoration(labelText: 'To'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => ctrl.updateCondition(
                  node.id,
                  node.copyWith(value2: num.tryParse(v) ?? v),
                ),
              ),
            ),
          ];
        }

        final v = node.value?.toString() ?? '';
        return [
          SizedBox(
            width: 200,
            child: TextFormField(
              initialValue: v,
              decoration: InputDecoration(labelText: fieldMeta.label),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (raw) => ctrl.updateCondition(
                node.id,
                node.copyWith(value: num.tryParse(raw) ?? raw),
              ),
            ),
          ),
        ];

      case FilterPropType.string:
        return [
          SizedBox(
            width: 220,
            child: TextFormField(
              initialValue: node.value?.toString() ?? '',
              decoration: InputDecoration(labelText: fieldMeta.label),
              onChanged: (v) =>
                  ctrl.updateCondition(node.id, node.copyWith(value: v)),
            ),
          ),
        ];

      case FilterPropType.date:
      case FilterPropType.datetime:
        // Generic date input for any date-like field
        if (node.predicate == Predicate.between) {
          final from = node.value is DateTime ? node.value as DateTime : null;
          final to = node.value2 is DateTime ? node.value2 as DateTime : null;
          return [
            _dateField(
              context: context,
              label: 'From',
              initial: from,
              onPicked: (d) => ctrl.updateCondition(node.id, node.copyWith(value: d)),
            ),
            const SizedBox(width: 8),
            _dateField(
              context: context,
              label: 'To',
              initial: to,
              onPicked: (d) => ctrl.updateCondition(node.id, node.copyWith(value2: d)),
            ),
          ];
        }
        final single = node.value is DateTime ? node.value as DateTime : null;
        return [
          _dateField(
            context: context,
            label: fieldMeta.label,
            initial: single,
            onPicked: (d) => ctrl.updateCondition(node.id, node.copyWith(value: d)),
          ),
        ];
    }
  }


  // Fallback: plain text input
  List<Widget> _fallbackText(ConditionNode node, FilterBuilderController ctrl) {
    return [
      SizedBox(
        width: 220,
        child: TextFormField(
          initialValue: node.value?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Value'),
          onChanged: (v) => ctrl.updateCondition(node.id, node.copyWith(value: v)),
        ),
      ),
    ];
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required DateTime? initial,
    required void Function(DateTime picked) onPicked,
  }) {
    final display = (DateTime? d) =>
        d == null ? '' : '${d.year.toString().padLeft(4, '0')}-'
            '${d.month.toString().padLeft(2, '0')}-'
            '${d.day.toString().padLeft(2, '0')}';

    return SizedBox(
      width: 200,
      child: InkWell(
        onTap: () async {
          final base = initial ?? DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: base,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            final normalized = DateTime(picked.year, picked.month, picked.day);
            onPicked(normalized);
          }
        },
        child: InputDecorator(
          isEmpty: initial == null,
          decoration: InputDecoration(
            labelText: label,
            // hintText: 'Pick a date',
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(display(initial).isEmpty ? ' ' : display(initial)),
        ),
      ),
    );
  }

  String _labelField(StudyField f) {
    switch (f) {
      case StudyField.title:
        return 'Title';
      case StudyField.status:
        return 'Status';
      case StudyField.owner:
        return 'Owner';
      case StudyField.createdAt:
        return 'Created at';
      case StudyField.resultSharing:
        return 'Result sharing';
      case StudyField.registryPublished:
        return 'Registry published';
      case StudyField.participation:
        return 'Participation';
      case StudyField.totalMissedDays:
        return 'Total missed days';
    }
  }

  String _labelPredicate(Predicate p) {
    switch (p) {
      case Predicate.equals:
        return 'equals';
      case Predicate.notEquals:
        return 'not equals';
      case Predicate.contains:
        return 'contains';
      case Predicate.lessThan:
        return '<';
      case Predicate.greaterThan:
        return '>';
      case Predicate.between:
        return 'between';
      case Predicate.inLastDays:
        return 'in last (days)';
      case Predicate.isTrue:
        return 'is true';
      case Predicate.isFalse:
        return 'is false';
    }
  }
}


