import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/advanced_filters_model.dart';
import 'package:studyu_designer_v2/domain/saved_filters.dart';
import 'package:studyu_designer_v2/localization/effective_filter_provider.dart';

import 'all_studies_provider.dart';

final filteredStudiesProvider =
    Provider<AsyncValue<List<Study>>>((ref) {
  final allAsync = ref.watch(allStudiesProvider);
  final effective = ref.watch(effectiveFilterProvider);

  return allAsync.whenData((all) {
    if (effective == null) return all;

    var filtered = all.where(
      (s) => _matchesGroup(s, effective.logicTree),
    ).toList();

    final sort = effective.sortPreset;
    if (sort != null) {
      filtered.sort((a, b) => _compareWithSort(a, b, sort));
    }

    return filtered;
  });
});

bool _matchesGroup(Study study, GroupNode group) {
  if (group.children.isEmpty) return true; // empty group = match all

  final results = group.children.map((node) {
    if (node is GroupNode) return _matchesGroup(study, node);
    if (node is ConditionNode) return _matchesCondition(study, node);
    return true;
  });

  if (group.op == LogicalOp.and) {
    return results.every((r) => r);
  } else {
    return results.any((r) => r);
  }
}

bool _matchesCondition(Study study, ConditionNode c) {
  final fieldValue = _fieldValue(study, c.field);

  switch (c.predicate) {
    case Predicate.equals:
      return fieldValue == c.value;
    case Predicate.notEquals:
      return fieldValue != c.value;
    case Predicate.contains:
      final s = (fieldValue ?? '').toString().toLowerCase();
      final q = (c.value ?? '').toString().toLowerCase();
      return s.contains(q);
    case Predicate.lessThan:
      return _cmp(fieldValue, c.value) < 0;
    case Predicate.greaterThan:
      return _cmp(fieldValue, c.value) > 0;
    case Predicate.between:
      return _cmp(fieldValue, c.value) >= 0 &&
          _cmp(fieldValue, c.value2) <= 0;
    case Predicate.inLastDays:
      if (fieldValue is! DateTime) return false;
      final days = (c.value is int)
          ? c.value as int
          : int.tryParse('${c.value}') ?? 30;
      final since = DateTime.now().subtract(Duration(days: days));
      return fieldValue.isAfter(since);
    case Predicate.isTrue:
      return fieldValue == true;
    case Predicate.isFalse:
      return fieldValue == false;
  }
}

Object? _fieldValue(Study s, StudyField f) {
  switch (f) {
    case StudyField.title:
      return s.title;

    case StudyField.status:
      // TODO: adjust to your actual type; often StudyStatus enum → string
      // e.g. return s.status.name;
      return s.status.name;

    case StudyField.owner:
      // TODO: map to whatever you use for "Owner is me" / "Owner is X"
      // e.g. s.ownerId or s.owner.email
      return s.contact.email;

    case StudyField.createdAt:
      return s.createdAt; // DateTime

    case StudyField.resultSharing:
      // TODO: adapt field
      // e.g. s.sharingPolicy.name ('public'/'private')
      return s.resultSharing;

    case StudyField.registryPublished:
      // TODO: adapt to your registry flag
      return s.registryPublished;

    case StudyField.participation:
      // TODO: use your actual metric, e.g. s.dashboardMetrics.participationRate
      return s.participation;

    case StudyField.totalMissedDays:
      // TODO: adapt field: e.g. s.dashboardMetrics.totalMissedDays
      return s.totalMissedDays;
  }
}

int _cmp(Object? a, Object? b) {
  if (a == null || b == null) return 0;

  if (a is num && b is num) {
    return a.compareTo(b);
  }
  if (a is DateTime && b is DateTime) {
    return a.compareTo(b);
  }
  return a.toString().compareTo(b.toString());
}

int _compareWithSort(Study a, Study b, SortPreset sort) {
  Object? va;
  Object? vb;

  switch (sort.columnKey) {
    case 'createdAt':
      va = a.createdAt;
      vb = b.createdAt;
      break;
    case 'title':
      va = a.title;
      vb = b.title;
      break;
    case 'status':
      va = a.status.name;
      vb = b.status.name;
      break;
    default:
      va = a.createdAt;
      vb = b.createdAt;
  }

  final base = _cmp(va, vb);
  return sort.direction == SortDirection.asc ? base : -base;
}
