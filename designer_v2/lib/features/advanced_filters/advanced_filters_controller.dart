import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/advanced_filters_model.dart';

final filterBuilderProvider =
    StateNotifierProvider<FilterBuilderController, FilterDraft>(
  (ref) => FilterBuilderController.initial(),
);


/// Null = no active advanced filter
final activeFilterDraftProvider = StateProvider<FilterDraft?>((_) => null);

class FilterBuilderController extends StateNotifier<FilterDraft> {
  FilterBuilderController(FilterDraft state) : super(state);

  factory FilterBuilderController.initial() {
    return FilterBuilderController(
      FilterDraft(root: GroupNode(id: newId(), op: LogicalOp.and, children: const [])),
    );
  }

  // public API
  void setGroupOp(String groupId, LogicalOp op) {
    state = state.copyWith(root: _updateGroup(state.root, groupId, (g) => g.copyWith(op: op)));
  }

  // Remove the last ConditionNode in DFS order; returns true if something was removed.
  bool removeLastCondition(String groupId) {
    final draft = state; // assuming this is a StateNotifier with `state` exposing the draft
    final root = draft.root;

    ConditionNode? last;
    GroupNode? parentOfLast;

    void dfs(GroupNode g) {
      for (final n in g.children) {
        if (n is GroupNode) dfs(n);
        if (n is ConditionNode) {
          last = n;
          parentOfLast = g;
        }
      }
    }

    dfs(root);
    if (last == null || parentOfLast == null) return false;

    parentOfLast!.children.removeWhere((n) => n.id == last!.id);
    // write back the updated draft
    state = draft.copyWith(root: root);
    return true;
  }

  void clearAllConditions() {
    final draft = state;
    draft.root.children.clear();
    state = draft.copyWith(root: draft.root);
  }



  void addCondition(String parentGroupId) {
    final node = ConditionNode(
      id: newId(),
      field: StudyField.status,
      predicate: Predicate.equals,
      value: 'draft',
    );
    _insertChild(parentGroupId, node);
  }

  void addGroup(String parentGroupId) {
    _insertChild(parentGroupId, GroupNode(id: newId(), op: LogicalOp.and, children: const []));
  }

  void removeNode(String nodeId) {
    state = state.copyWith(root: _removeNode(state.root, nodeId));
  }

  void updateCondition(String nodeId, ConditionNode updated) {
    state = state.copyWith(root: _updateCondition(state.root, nodeId, updated));
  }

  void reset() {
    state = FilterBuilderController.initial().state;
  }

  // helpers
  void _insertChild(String parentGroupId, FilterNode child) {
    state = state.copyWith(
      root: _updateGroup(state.root, parentGroupId,
          (g) => g.copyWith(children: [...g.children, child])),
    );
  }

  GroupNode _updateGroup(
    GroupNode current,
    String targetId,
    GroupNode Function(GroupNode) fn,
  ) {
    if (current.id == targetId) return fn(current);
    final kids = current.children.map((c) {
      if (c is GroupNode) return _updateGroup(c, targetId, fn);
      return c;
    }).toList();
    return current.copyWith(children: kids);
  }

  GroupNode _removeNode(GroupNode current, String nodeId) {
    final next = <FilterNode>[];
    for (final c in current.children) {
      if (c.id == nodeId) continue;
      if (c is GroupNode) {
        next.add(_removeNode(c, nodeId));
      } else {
        next.add(c);
      }
    }
    // never delete root itself
    return current.copyWith(children: next);
  }

  GroupNode _updateCondition(GroupNode current, String nodeId, ConditionNode updated) {
    final kids = current.children.map((c) {
      if (c is ConditionNode && c.id == nodeId) return updated;
      if (c is GroupNode) return _updateCondition(c, nodeId, updated);
      return c;
    }).toList();
    return current.copyWith(children: kids);
  }
}
