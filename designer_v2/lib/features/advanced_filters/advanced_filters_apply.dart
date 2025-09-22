import 'package:studyu_core/core.dart' show Study;
import 'package:studyu_designer_v2/domain/advanced_filters_model.dart';

typedef StudyPredicate = bool Function(Study s);

/// Top-level: convert a FilterDraft → predicate.
/// NOTE: Map your Study fields inside helpers below (TODOs).
StudyPredicate compileToPredicate(FilterDraft draft, {String? meId, String? meEmail}) {
  return (Study s) => _evalGroup(draft.root, s, meId: meId, meEmail: meEmail);
}

bool _evalGroup(GroupNode g, Study s, {String? meId, String? meEmail}) {
  final results = g.children.map((n) {
    if (n is GroupNode) return _evalGroup(n, s, meId: meId, meEmail: meEmail);
    if (n is ConditionNode) return _evalCond(n, s, meId: meId, meEmail: meEmail);
    return true;
  });

  return switch (g.op) {
    LogicalOp.and => results.every((r) => r),
    LogicalOp.or  => results.any((r) => r),
  };
}

bool _evalCond(ConditionNode c, Study s, {String? meId, String? meEmail}) {
  switch (c.field) {
    case StudyField.title:
      final title = _studyTitle(s) ?? '';
      final val = (c.value ?? '').toString();
      return _cmpString(title, c.predicate, val);

    case StudyField.status:
      final status = (_studyStatus(s) ?? '').toLowerCase();
      final val = (c.value ?? '').toString().toLowerCase();
      return _cmpString(status, c.predicate, val);

    case StudyField.owner:
      final owner = (_studyOwnerIdOrEmail(s) ?? '').toLowerCase();
      final target = ((c.value ?? '').toString().toLowerCase());
      final me = (target == 'me') ? (meId ?? meEmail ?? '') : target;
      return _cmpString(owner, c.predicate, me);

    case StudyField.createdAt:
      final created = _studyCreatedAt(s);
      if (created == null) return false;
      return switch (c.predicate) {
        Predicate.inLastDays => _inLastDays(created, _asInt(c.value) ?? 30),
        Predicate.lessThan   => created.isBefore(_asDate(c.value) ?? created),
        Predicate.greaterThan=> created.isAfter(_asDate(c.value) ?? created),
        Predicate.between    => _betweenDate(created, _asDate(c.value), _asDate(c.value2)),
        _ => false,
      };

    case StudyField.resultSharing:
      final rs = (_studyResultSharing(s) ?? '').toLowerCase();
      final val = (c.value ?? '').toString().toLowerCase();
      return _cmpString(rs, c.predicate, val);

    case StudyField.registryPublished:
      final pub = _studyRegistryPublished(s) ?? false;
      return switch (c.predicate) {
        Predicate.isTrue  => pub == true,
        Predicate.isFalse => pub == false,
        _ => false,
      };

    case StudyField.participation:
      final numv = _studyParticipation(s);
      return _cmpNum(numv, c);

    case StudyField.totalMissedDays:
      final numv = _studyTotalMissedDays(s);
      return _cmpNum(numv, c);
  }
}

/// ---- Comparators

bool _cmpString(String left, Predicate p, String right) => switch (p) {
  Predicate.equals     => left == right,
  Predicate.notEquals  => left != right,
  Predicate.contains   => left.contains(right),
  _ => false,
};

bool _cmpNum(num? left, ConditionNode c) {
  if (left == null) return false;
  final a = _asNum(c.value);
  final b = _asNum(c.value2);
  return switch (c.predicate) {
    Predicate.equals      => left == a,
    Predicate.notEquals   => left != a,
    Predicate.lessThan    => left <  (a ?? left),
    Predicate.greaterThan => left >  (a ?? left),
    Predicate.between     => (a != null && b != null) ? (left >= a && left <= b) : false,
    _ => false,
  };
}

bool _inLastDays(DateTime dt, int days) {
  final now = DateTime.now();
  final since = now.subtract(Duration(days: days));
  return !dt.isBefore(since);
}

bool _betweenDate(DateTime dt, DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  final start = a.isBefore(b) ? a : b;
  final end   = a.isBefore(b) ? b : a;
  return (dt.isAfter(start) || dt.isAtSameMomentAs(start)) &&
         (dt.isBefore(end)  || dt.isAtSameMomentAs(end));
}

/// ---- Type helpers

int? _asInt(Object? v) => switch (v) {
  null => null,
  int i => i,
  String s => int.tryParse(s),
  _ => null,
};

num? _asNum(Object? v) => switch (v) {
  null => null,
  num n => n,
  String s => num.tryParse(s),
  _ => null,
};

DateTime? _asDate(Object? v) {
  if (v is DateTime) return v;
  if (v is String) {
    try { return DateTime.parse(v); } catch (_) { return null; }
  }
  return null;
}

/// ---- Study field adapters (adjust to your real fields) ----
/// Replace the bodies below with the actual Study model fields used in StudyU.

String? _studyTitle(Study s) {
  try { return (s as dynamic).title as String?; } catch (_) {}
  try { return (s as dynamic).name as String?; } catch (_) {}
  return null;
}

String? _studyStatus(Study s) {
  try {
    final st = (s as dynamic).status;
    return st is Enum ? st.name : st?.toString();
  } catch (_) { return null; }
}

String? _studyOwnerIdOrEmail(Study s) {
  try { return (s as dynamic).ownerId as String?; } catch (_) {}
  try { return (s as dynamic).createdBy as String?; } catch (_) {}
  try { return (s as dynamic).ownerEmail as String?; } catch (_) {}
  return null;
}

DateTime? _studyCreatedAt(Study s) {
  try { return (s as dynamic).createdAt as DateTime?; } catch (_) {}
  try {
    final sdt = (s as dynamic).creationDate as String?;
    return sdt != null ? DateTime.tryParse(sdt) : null;
  } catch (_) {}
  return null;
}

String? _studyResultSharing(Study s) {
  try {
    final val = (s as dynamic).resultSharing;
    return val is Enum ? val.name : val?.toString();
  } catch (_) { return null; }
}

bool? _studyRegistryPublished(Study s) {
  try { return (s as dynamic).registryPublished as bool?; } catch (_) {}
  try { return (s as dynamic).isPublishedToRegistry as bool?; } catch (_) {}
  return null;
}

num? _studyParticipation(Study s) {
  try { return (s as dynamic).metrics?.participation as num?; } catch (_) {}
  try { return (s as dynamic).participation as num?; } catch (_) {}
  return null;
}

num? _studyTotalMissedDays(Study s) {
  try { return (s as dynamic).metrics?.totalMissedDays as num?; } catch (_) {}
  try { return (s as dynamic).totalMissedDays as num?; } catch (_) {}
  return null;
}
