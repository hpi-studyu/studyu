import 'package:studyu_designer_v2/domain/saved_filters.dart';

import '../../domain/advanced_filters_model.dart'
    show
        StudyField,
        LogicalOp,
        Predicate,
        FilterNode,
        GroupNode,
        ConditionNode,
        newId;

/// Thresholds used in "Studies Needing Attention"
class GlobalThresholds {
  final double lowParticipation; // e.g. 0.6 = 60%
  final int highMissedDays;      // e.g. 10 days

  const GlobalThresholds({
    this.lowParticipation = 0.6,
    this.highMissedDays = 10,
  });
}

/// Convenience helpers for building groups & conditions
GroupNode _and(List<FilterNode> children) => GroupNode(
      id: newId(),
      op: LogicalOp.and,
      children: children,
    );

GroupNode _or(List<FilterNode> children) => GroupNode(
      id: newId(),
      op: LogicalOp.or,
      children: children,
    );

ConditionNode _c({
  required StudyField field,
  required Predicate predicate,
  Object? value,
  Object? value2,
}) =>
    ConditionNode(
      id: newId(),
      field: field,
      predicate: predicate,
      value: value,
      value2: value2,
    );

/// ------- Built-in Quick Presets (logic only) -------
/// These return a `SavedFilter` *shape* you can:
///  - apply directly to the dashboard, OR
///  - "Save as…" to persist into user preferences.

class QuickPresets {
  /// My Active Studies = Owner is me AND Status = running
  static SavedFilter myActiveStudies(FilterScope scope) => SavedFilter(
        id: 'preset-my-active', // purely logical id; real saved one will be new uuid
        name: 'My Active Studies',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        scope: scope,
        logicTree: _and([
          _c(
            field: StudyField.owner,
            predicate: Predicate.equals,
            value: 'me', // your backend resolves "me" → current user
          ),
          _c(
            field: StudyField.status,
            predicate: Predicate.equals,
            value: 'running',
          ),
        ]),
        sortPreset: null,
      );

  /// Studies Needing Attention = Participation < lowParticipation
  /// OR TotalMissedDays > highMissedDays
  static SavedFilter studiesNeedingAttention(
    FilterScope scope,
    GlobalThresholds t,
  ) =>
      SavedFilter(
        id: 'preset-attention',
        name: 'Studies Needing Attention',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        scope: scope,
        logicTree: _or([
          _c(
            field: StudyField.participation,
            predicate: Predicate.lessThan,
            value: t.lowParticipation,
          ),
          _c(
            field: StudyField.totalMissedDays,
            predicate: Predicate.greaterThan,
            value: t.highMissedDays,
          ),
        ]),
        sortPreset: null,
      );

  /// Recently Created = CreatedAt in last N days (default 30), sort desc
  static SavedFilter recentlyCreated(
    FilterScope scope, {
    int days = 30,
  }) =>
      SavedFilter(
        id: 'preset-recent',
        name: 'Recently Created',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        scope: scope,
        logicTree: _and([
          _c(
            field: StudyField.createdAt,
            predicate: Predicate.inLastDays,
            value: days,
          ),
        ]),
        sortPreset: const SortPreset(
          columnKey: 'createdAt',
          direction: SortDirection.desc,
        ),
      );

  /// Public Studies = ResultSharing = public OR RegistryPublished = true
  static SavedFilter publicStudies(FilterScope scope) => SavedFilter(
        id: 'preset-public',
        name: 'Public Studies',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        scope: scope,
        logicTree: _or([
          _c(
            field: StudyField.resultSharing,
            predicate: Predicate.equals,
            value: 'public',
          ),
          _c(
            field: StudyField.registryPublished,
            predicate: Predicate.isTrue,
          ),
        ]),
        sortPreset: null,
      );

  /// Draft Studies = Status = draft
  static SavedFilter draftStudies(FilterScope scope) => SavedFilter(
        id: 'preset-draft',
        name: 'Draft Studies',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        scope: scope,
        logicTree: _and([
          _c(
            field: StudyField.status,
            predicate: Predicate.equals,
            value: 'draft',
          ),
        ]),
        sortPreset: null,
      );
}
