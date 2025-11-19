import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/domain/advanced_filters_model.dart';
import 'package:studyu_designer_v2/domain/saved_filters.dart';
import 'package:studyu_designer_v2/features/advanced_filters/advanced_filters_apply.dart';
import 'package:studyu_designer_v2/features/advanced_filters/advanced_filters_controller.dart';
import 'package:studyu_designer_v2/features/advanced_filters/advanced_filters_entry_button.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_scaffold.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/filtered_studies_provider.dart';
import 'package:studyu_designer_v2/localization/saved_filters_controller.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:studyu_designer_v2/utils/empty_state.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.filter, super.key});

  final StudiesFilter? filter;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  bool _appliedDefaultOnce = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final def = ref.read(defaultFilterProvider);   // read is fine here
      if (def != null) {
        ref.read(activeFilterFromSavedProvider.notifier).state = def;
        ref.read(savedFiltersProvider.notifier).touchLastUsed(def.id);
      }
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (_appliedDefaultOnce) return;         // run once per mount
  //   _appliedDefaultOnce = true;

  //   final def = ref.read(defaultFilterProvider); // read (not watch)
  //   if (def != null) {
  //     ref.read(activeFilterFromSavedProvider.notifier).state = def;
  //     ref.read(savedFiltersProvider.notifier).touchLastUsed(def.id);
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedDefaultOnce) return;
    _appliedDefaultOnce = true;

    final def = ref.read(defaultFilterProvider);
    if (def != null) {
      ref.read(activeFilterFromSavedProvider.notifier).state = def; // APPLY
      ref.read(savedFiltersProvider.notifier).touchLastUsed(def.id);      
    }
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
    final FilterDraft builderDraft = ref.watch(filterBuilderProvider);
    final bool hasActiveFilter = flattenConditions(builderDraft.root).isNotEmpty;

    

    return DashboardScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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

          const SizedBox(height: 24.0),
          if (hasActiveFilter)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(child: ActiveFilterChips(draft: builderDraft)),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear all'),
                  onPressed: () => _clearAllFilters(ref),
                ),
              ],
            ),
          ),

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

                  final filtered = !hasActiveFilter
                        ? visibleStudies
                        : visibleStudies
                            .where(compileToPredicate(builderDraft, meId: meId, meEmail: meEmail))
                            .toList();

                   // If no matches after applying filters/search, show helpful empty-state.
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: EmptyState(
                        icon: Icons.content_paste_search_rounded,
                        title: hasActiveFilter ? tr.studies_not_found : tr.studies_empty,
                        message: hasActiveFilter
                            ? tr.modify_query
                            : tr.studies_empty_description,
                        primaryLabel: hasActiveFilter ? 'Remove last condition' : null,
                        onPrimary: hasActiveFilter ? () => _removeLastCondition(ref) : null,
                        secondaryLabel: hasActiveFilter ? 'Clear all filters' : null,
                        onSecondary: hasActiveFilter ? () => _clearAllConditions(ref) : null,
                      ),
                    );
                  }


                  // Otherwise render the table as usual
                  return StudiesTable(
                    studies: filtered,
                    pinnedStudies: snapshot.data!.preferences.pinnedStudies,
                    dashboardController: ref.watch(dashboardControllerProvider.notifier),
                    onSelect: controller.onSelectStudy,
                    getActions: controller.availableActions, emptyWidget: Container(),
                  );

                },
              );
            },
          ),

        ],
      ),
    );
  }
  void _clearAllFilters(WidgetRef ref) {
    // 1) Reset the builder (wipes the draft tree)
    ref.read(filterBuilderProvider.notifier).reset();

    // 2) Remove the active draft so chips disappear & filtering stops
    ref.read(activeFilterDraftProvider.notifier).state = null;

    // 3) (Optional) also clear the free-text search box
    final dash = ref.read(dashboardControllerProvider);
    dash.searchController.clear();
    ref.read(dashboardControllerProvider.notifier).filterStudies('');
  }

  void _clearAllConditions(WidgetRef ref) {
    final ctrl = ref.read(filterBuilderProvider.notifier);
    // If you already have `reset()`, this is enough:
    ctrl.reset();
    // Also clear the active draft so chips disappear
    ref.read(activeFilterDraftProvider.notifier).state = null;
  }

  void _removeLastCondition(WidgetRef ref) {
    final draft = ref.read(filterBuilderProvider);
    final ctrl = ref.read(filterBuilderProvider.notifier);

    // Find last ConditionNode depth-first
    ConditionNode? last;
    GroupNode? parent;

    void dfs(GroupNode g) {
      for (final n in g.children) {
        if (n is GroupNode) dfs(n);
        if (n is ConditionNode) {
          last = n;
          parent = g;
        }
      }
    }

    dfs(draft.root);

    if (last != null && parent != null) {
      // Use your existing remove API if present
      ctrl.removeNode(last!.id);
    } else {
      // Nothing to remove -> clear all as fallback
      _clearAllConditions(ref);
    }
  }


 
  bool _sameChildren(List<FilterNode> a, List<FilterNode> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i])) return false;
    }
    return true;
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

  




// ===== Active Filter Chips (display + remove) ===============================

class ActiveFilterChips extends ConsumerWidget {
  const ActiveFilterChips({super.key, required this.draft});
  final FilterDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditions = flattenConditions(draft.root);
    if (conditions.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: conditions.map((c) {
          final text = prettyCondition(c);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InputChip(
              label: Text(text),
              onDeleted: () {
                final newRoot = removeNodeById(draft.root, c.id);
                if (newRoot == null) {
                  // no nodes left → clear active draft entirely
                  ref.read(activeFilterDraftProvider.notifier).state = null;
                } else {
                  ref.read(activeFilterDraftProvider.notifier).state =
                      draft.copyWith(root: newRoot);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---- Model walking & transforms ----

List<ConditionNode> flattenConditions(GroupNode root) {
  final out = <ConditionNode>[];
  void dfs(FilterNode node) {
    if (node is ConditionNode) {
      out.add(node);
    } else if (node is GroupNode) {
      for (final child in node.children) {
        dfs(child);
      }
    }
  }
  dfs(root);
  return out;
}

/// Remove node by id from the tree. Returns a new root or null if empty.
GroupNode? removeNodeById(GroupNode root, String id) {
  FilterNode? prune(FilterNode node) {
    if (node.id == id) return null;

    if (node is GroupNode) {
      final nextChildren = <FilterNode>[];
      for (final child in node.children) {
        final pruned = prune(child);
        if (pruned != null) nextChildren.add(pruned);
      }
      // If group becomes empty, drop the group (unless it's the root)
      if (nextChildren.isEmpty && node != root) return null;
      if (sameChildren(node.children, nextChildren)) return node;
      return node.copyWith(children: nextChildren);
    }
    // ConditionNode with other id stays
    return node;
  }

  final prunedRoot = prune(root);
  if (prunedRoot == null) return null;
  if (prunedRoot is GroupNode) return prunedRoot;

  // If somehow not a group anymore, wrap into a minimal group
  return GroupNode(
    id: root.id,
    op: root.op,
    children: [prunedRoot],
  );
}

bool sameChildren(List<FilterNode> a, List<FilterNode> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!identical(a[i], b[i])) return false;
  }
  return true;
}

// ---- Human-readable labels ----

String prettyCondition(ConditionNode c) {
  final field = labelFieldChip(c.field);
  final op = labelPredicateChip(c.predicate);

  switch (c.field) {
    case StudyField.createdAt:
      return prettyCreatedAt(c, field, op);
    default:
      return prettyGeneric(c, field, op);
  }
}

String prettyCreatedAt(ConditionNode c, String field, String op) {
  switch (c.predicate) {
    case Predicate.inLastDays:
      final label = prettyInLastDays(c.value);
      return '$field: $label';

    case Predicate.between:
      return '$field between ${displayDate(c.value)} and ${displayDate(c.value2)}';

    case Predicate.lessThan:
    case Predicate.greaterThan:
      return '$field $op ${displayDate(c.value)}';

    default:
      return '$field $op';
  }
}

String displayDate(Object? v) {
  if (v is DateTime) {
    final y = v.year.toString().padLeft(4, '0');
    final m = v.month.toString().padLeft(2, '0');
    final d = v.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
  return v?.toString() ?? '';
}

/// Human-friendly text for "inLastDays" without depending on CreatedAtPreset
String prettyInLastDays(Object? v) {
  if (v == null) return 'any time';

  // direct numbers
  if (v is int) return 'last $v days';
  if (v is String) {
    final n = int.tryParse(v);
    if (n != null) return 'last $n days';
    // handle string enums/labels fallback
    final s = v.toLowerCase();
    if (s.contains('any')) return 'any time';
    if (s.contains('7')) return 'last 7 days';
    if (s.contains('30')) return 'last 30 days';
    if (s.contains('90')) return 'last 90 days';
    if (s.contains('180')) return 'last 180 days';
    if (s.contains('custom')) return '(custom range)';
    return v; // e.g., an already user-readable label
  }

  // Enum fallback (no specific type import needed)
  if (v is Enum) {
    final name = v.toString().split('.').last.toLowerCase(); // e.g., 'last7d'
    switch (name) {
      case 'any': return 'any time';
      case 'last7d': return 'last 7 days';
      case 'last30d': return 'last 30 days';
      case 'last90d': return 'last 90 days';
      case 'last180d': return 'last 180 days';
      case 'customrange': return '(custom range)';
      default:
        final digits = RegExp(r'\d+').firstMatch(name)?.group(0);
        if (digits != null) return 'last $digits days';
        return name;
    }
  }

  // Last resort
  return v.toString();
}

String prettyGeneric(ConditionNode c, String field, String op) {
  String val(Object? v) {
    if (v == null) return '""';
    if (v is DateTime) {
      final y = v.year.toString().padLeft(4, '0');
      final m = v.month.toString().padLeft(2, '0');
      final d = v.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    if (v is String) return '"$v"';
    return v.toString();
  }

  switch (c.predicate) {
    case Predicate.between:
      return '$field between ${val(c.value)} and ${val(c.value2)}';
    case Predicate.isTrue:
      return '$field is true';
    case Predicate.isFalse:
      return '$field is false';
    default:
      return '$field $op ${val(c.value)}';
  }
}

// Keep labels consistent with your builder UI
String labelFieldChip(StudyField f) {
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

String labelPredicateChip(Predicate p) {
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
