import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './advanced_filters_controller.dart';
import '../../domain/advanced_filters_model.dart';

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
            Spacer(),
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
        final narrow = constraints.maxWidth < 520; // ✅ stack on narrow
 
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
              ctrl.updateCondition(node.id, node.copyWith(field: f, value: null, value2: null));
            },
          ),
        );
 
        final opDropdown = SizedBox(
          width: narrow ? double.infinity : 200,
          child: DropdownButtonFormField<Predicate>(
            value: node.predicate,
            decoration: const InputDecoration(labelText: 'Operator'),
            items: _allowedPredicates(node.field)
                .map((p) => DropdownMenuItem(value: p, child: Text(_labelPredicate(p))))
                .toList(),
            onChanged: (p) {
              if (p == null) return;
              ctrl.updateCondition(node.id, node.copyWith(predicate: p, value: null, value2: null));
            },
          ),
        );
 
        // ✅ Value editors expand to available width
        List<Widget> valueEditors = _valueEditors(node, ctrl)
            .map((w) => narrow ? w : Expanded(child: w)) // expand on wide
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
              ...valueEditors.map((w) => Padding(padding: const EdgeInsets.only(bottom: 8), child: w)),
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

  List<Predicate> _allowedPredicates(StudyField field) {
    switch (field) {
      case StudyField.title:
      case StudyField.owner:
      case StudyField.status:
      case StudyField.resultSharing:
        return const [Predicate.equals, Predicate.notEquals, Predicate.contains];
      case StudyField.registryPublished:
        return const [Predicate.isTrue, Predicate.isFalse];
      case StudyField.participation:
      case StudyField.totalMissedDays:
        return const [
          Predicate.equals, Predicate.notEquals, Predicate.lessThan,
          Predicate.greaterThan, Predicate.between
        ];
      case StudyField.createdAt:
        return const [Predicate.lessThan, Predicate.greaterThan, Predicate.between, Predicate.inLastDays];
    }
  }

  List<Widget> _valueEditors(ConditionNode node, FilterBuilderController ctrl) {
    // specialized editors (status/resultSharing could become dropdowns later)
    switch (node.predicate) {
      case Predicate.isTrue:
      case Predicate.isFalse:
        return const []; // no values
      case Predicate.between:
        return [
          SizedBox(
            width: 160,
            child: TextFormField(
              initialValue: node.value?.toString() ?? '',
              decoration: const InputDecoration(labelText: 'From'),
              onChanged: (v) => ctrl.updateCondition(node.id, node.copyWith(value: v)),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 160,
            child: TextFormField(
              initialValue: node.value2?.toString() ?? '',
              decoration: const InputDecoration(labelText: 'To'),
              onChanged: (v) => ctrl.updateCondition(node.id, node.copyWith(value2: v)),
            ),
          ),
        ];
      case Predicate.inLastDays:
        return [
          SizedBox(
            width: 140,
            child: TextFormField(
              initialValue: node.value?.toString() ?? '30',
              decoration: const InputDecoration(labelText: 'Days'),
              keyboardType: TextInputType.number,
              onChanged: (v) => ctrl.updateCondition(
                node.id,
                node.copyWith(value: int.tryParse(v) ?? v),
              ),
            ),
          ),
        ];
      default:
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
  }

  String _labelField(StudyField f) {
    switch (f) {
      case StudyField.title: return 'Title';
      case StudyField.status: return 'Status';
      case StudyField.owner: return 'Owner';
      case StudyField.createdAt: return 'Created at';
      case StudyField.resultSharing: return 'Result sharing';
      case StudyField.registryPublished: return 'Registry published';
      case StudyField.participation: return 'Participation';
      case StudyField.totalMissedDays: return 'Total missed days';
    }
  }

  String _labelPredicate(Predicate p) {
    switch (p) {
      case Predicate.equals: return 'equals';
      case Predicate.notEquals: return 'not equals';
      case Predicate.contains: return 'contains';
      case Predicate.lessThan: return '<';
      case Predicate.greaterThan: return '>';
      case Predicate.between: return 'between';
      case Predicate.inLastDays: return 'in last (days)';
      case Predicate.isTrue: return 'is true';
      case Predicate.isFalse: return 'is false';
    }
  }
}
