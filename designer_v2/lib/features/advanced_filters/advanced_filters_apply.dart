// import 'package:studyu_core/core.dart' show Study;
// import 'package:studyu_designer_v2/domain/advanced_filters_model.dart';

// typedef StudyPredicate = bool Function(Study s);

// /// Top-level: convert a FilterDraft → predicate.
// /// NOTE: Map your Study fields inside helpers below (TODOs).
// StudyPredicate compileToPredicate(FilterDraft draft, {String? meId, String? meEmail}) {
//   return (Study s) => _evalGroup(draft.root, s, meId: meId, meEmail: meEmail);
// }

// bool _evalGroup(GroupNode g, Study s, {String? meId, String? meEmail}) {
//   final results = g.children.map((n) {
//     if (n is GroupNode) return _evalGroup(n, s, meId: meId, meEmail: meEmail);
//     if (n is ConditionNode) return _evalCond(n, s, meId: meId, meEmail: meEmail);
//     return true;
//   });

//   return switch (g.op) {
//     LogicalOp.and => results.every((r) => r),
//     LogicalOp.or  => results.any((r) => r),
//   };
// }

// bool _evalCond(ConditionNode c, Study s, {String? meId, String? meEmail}) {
//   switch (c.field) {
//     case StudyField.title:
//       final title = _studyTitle(s) ?? '';
//       final val = (c.value ?? '').toString();
//       return _cmpString(title, c.predicate, val);

//     case StudyField.status:
//       final status = (_studyStatus(s) ?? '').toLowerCase();
//       final val = (c.value ?? '').toString().toLowerCase();
//       return _cmpString(status, c.predicate, val);

//     case StudyField.owner:
//       final owner = (_studyOwnerIdOrEmail(s) ?? '').toLowerCase();
//       final target = ((c.value ?? '').toString().toLowerCase());
//       final me = (target == 'me') ? (meId ?? meEmail ?? '') : target;
//       return _cmpString(owner, c.predicate, me);

//     case StudyField.createdAt:
//       final created = _studyCreatedAt(s);
//       if (created == null) return false;
//       return switch (c.predicate) {
//         Predicate.inLastDays => _inLastDays(created, _asInt(c.value) ?? 30),
//         Predicate.lessThan   => created.isBefore(_asDate(c.value) ?? created),
//         Predicate.greaterThan=> created.isAfter(_asDate(c.value) ?? created),
//         Predicate.between    => _betweenDate(created, _asDate(c.value), _asDate(c.value2)),
//         _ => false,
//       };

//     case StudyField.resultSharing:
//       final rs = (_studyResultSharing(s) ?? '').toLowerCase();
//       final val = (c.value ?? '').toString().toLowerCase();
//       return _cmpString(rs, c.predicate, val);

//     case StudyField.registryPublished:
//       final pub = _studyRegistryPublished(s) ?? false;
//       return switch (c.predicate) {
//         Predicate.isTrue  => pub == true,
//         Predicate.isFalse => pub == false,
//         _ => false,
//       };

//     case StudyField.participation:
//       final numv = _studyParticipation(s);
//       return _cmpNum(numv, c);

//     case StudyField.totalMissedDays:
//       final numv = _studyTotalMissedDays(s);
//       return _cmpNum(numv, c);
//   }
// }

// /// ---- Comparators

// bool _cmpString(String left, Predicate p, String right) => switch (p) {
//   Predicate.equals     => left == right,
//   Predicate.notEquals  => left != right,
//   Predicate.contains   => left.contains(right),
//   _ => false,
// };

// bool _cmpNum(num? left, ConditionNode c) {
//   if (left == null) return false;
//   final a = _asNum(c.value);
//   final b = _asNum(c.value2);
//   return switch (c.predicate) {
//     Predicate.equals      => left == a,
//     Predicate.notEquals   => left != a,
//     Predicate.lessThan    => left <  (a ?? left),
//     Predicate.greaterThan => left >  (a ?? left),
//     Predicate.between     => (a != null && b != null) ? (left >= a && left <= b) : false,
//     _ => false,
//   };
// }

// bool _inLastDays(DateTime dt, int days) {
//   final now = DateTime.now();
//   final since = now.subtract(Duration(days: days));
//   return !dt.isBefore(since);
// }

// bool _betweenDate(DateTime dt, DateTime? a, DateTime? b) {
//   if (a == null || b == null) return false;
//   final start = a.isBefore(b) ? a : b;
//   final end   = a.isBefore(b) ? b : a;
//   return (dt.isAfter(start) || dt.isAtSameMomentAs(start)) &&
//          (dt.isBefore(end)  || dt.isAtSameMomentAs(end));
// }

// /// ---- Type helpers

// int? _asInt(Object? v) => switch (v) {
//   null => null,
//   int i => i,
//   String s => int.tryParse(s),
//   _ => null,
// };

// num? _asNum(Object? v) => switch (v) {
//   null => null,
//   num n => n,
//   String s => num.tryParse(s),
//   _ => null,
// };

// DateTime? _asDate(Object? v) {
//   if (v is DateTime) return v;
//   if (v is String) {
//     try { return DateTime.parse(v); } catch (_) { return null; }
//   }
//   return null;
// }

// /// ---- Study field adapters (adjust to your real fields) ----
// /// Replace the bodies below with the actual Study model fields used in StudyU.

// String? _studyTitle(Study s) {
//   try { return (s as dynamic).title as String?; } catch (_) {}
//   try { return (s as dynamic).name as String?; } catch (_) {}
//   return null;
// }

// String? _studyStatus(Study s) {
//   try {
//     final st = (s as dynamic).status;
//     return st is Enum ? st.name : st?.toString();
//   } catch (_) { return null; }
// }

// String? _studyOwnerIdOrEmail(Study s) {
//   try { return (s as dynamic).ownerId as String?; } catch (_) {}
//   try { return (s as dynamic).createdBy as String?; } catch (_) {}
//   try { return (s as dynamic).ownerEmail as String?; } catch (_) {}
//   return null;
// }

// DateTime? _studyCreatedAt(Study s) {
//   try { return (s as dynamic).createdAt as DateTime?; } catch (_) {}
//   try {
//     final sdt = (s as dynamic).creationDate as String?;
//     return sdt != null ? DateTime.tryParse(sdt) : null;
//   } catch (_) {}
//   return null;
// }

// String? _studyResultSharing(Study s) {
//   try {
//     final val = (s as dynamic).resultSharing;
//     return val is Enum ? val.name : val?.toString();
//   } catch (_) { return null; }
// }

// bool? _studyRegistryPublished(Study s) {
//   try { return (s as dynamic).registryPublished as bool?; } catch (_) {}
//   try { return (s as dynamic).isPublishedToRegistry as bool?; } catch (_) {}
//   return null;
// }

// num? _studyParticipation(Study s) {
//   try { return (s as dynamic).metrics?.participation as num?; } catch (_) {}
//   try { return (s as dynamic).participation as num?; } catch (_) {}
//   return null;
// }

// num? _studyTotalMissedDays(Study s) {
//   try { return (s as dynamic).metrics?.totalMissedDays as num?; } catch (_) {}
//   try { return (s as dynamic).totalMissedDays as num?; } catch (_) {}
//   return null;
// }

// lib/features/advanced_filters/advanced_filters_apply.dart
import 'package:flutter/foundation.dart';
import 'package:studyu_core/core.dart'; // for Study
import 'package:studyu_designer_v2/features/advanced_filters/created_at_filter.dart';
import 'package:studyu_designer_v2/features/advanced_filters/advanced_filters_state.dart';
import 'package:studyu_designer_v2/domain/advanced_filters_model.dart';

/// Decoupled field accessor for any row type T.
typedef FieldGetter<T> = Object? Function(T row);

/// Public: Apply filters to any list using explicit getters (generic).
List<T> applyAdvancedFilters<T>(
  List<T> rows,
  FilterDraft? draft,
  Map<StudyField, FieldGetter<T>> getters, {
  DateTime? now,
  String? meId,
  String? meEmail,
}) {
  if (draft == null) return rows;
  final root = draft.root;
  if (root.children.isEmpty) return rows;

  // ✅ FIX: use the generic compiler
  final test = compileToPredicateTyped<T>(
    draft,
    getters: getters,
    now: now,
    meId: meId,
    meEmail: meEmail,
  );
  return rows.where(test).toList(growable: false);
}

/// Public: Back-compat helper used by Dashboard.
/// Returns a predicate over `Study` directly. No changes needed in the screen.
bool Function(Study) compileToPredicate(
  FilterDraft draft, {
  DateTime? now,
  String? meId,
  String? meEmail,
}) {
  return compileToPredicateTyped<Study>(
    draft,
    getters: _defaultStudyGetters(),
    now: now,
    meId: meId,
    meEmail: meEmail,
  );
}

/// Generic typed compiler (use this if you want custom row types elsewhere).
bool Function(T) compileToPredicateTyped<T>(
  FilterDraft draft, {
  required Map<StudyField, FieldGetter<T>> getters,
  DateTime? now,
  String? meId,
  String? meEmail,
}) {
  return (T row) => _evalGroup<T>(
        draft.root,
        row,
        getters,
        now ?? DateTime.now(),
        meId: meId,
        meEmail: meEmail,
      );
}

// ---------------------------------------------------------------------------
// Evaluator
// ---------------------------------------------------------------------------

bool _evalGroup<T>(
  GroupNode group,
  T row,
  Map<StudyField, FieldGetter<T>> getters,
  DateTime now, {
  String? meId,
  String? meEmail,
}) {
  if (group.children.isEmpty) return true;

  if (group.op == LogicalOp.and) {
    for (final child in group.children) {
      if (child is GroupNode) {
        if (!_evalGroup(child, row, getters, now, meId: meId, meEmail: meEmail)) {
          return false;
        }
      } else if (child is ConditionNode) {
        if (!_evalCondition(child, row, getters, now, meId: meId, meEmail: meEmail)) {
          return false;
        }
      }
    }
    return true;
  } else {
    for (final child in group.children) {
      if (child is GroupNode) {
        if (_evalGroup(child, row, getters, now, meId: meId, meEmail: meEmail)) {
          return true;
        }
      } else if (child is ConditionNode) {
        if (_evalCondition(child, row, getters, now, meId: meId, meEmail: meEmail)) {
          return true;
        }
      }
    }
    return false;
  }
}

bool _evalCondition<T>(
  ConditionNode node,
  T row,
  Map<StudyField, FieldGetter<T>> getters,
  DateTime now, {
  String? meId,
  String? meEmail,
}) {
  final getter = getters[node.field];
  final left = getter != null ? getter(row) : null;

  // Boolean unary
  switch (node.predicate) {
    case Predicate.isTrue:
      return _asBool(left) == true;
    case Predicate.isFalse:
      return _asBool(left) == false;
    default:
      break;
  }

  // createdAt special handling (presets + dates)
  if (node.field == StudyField.createdAt) {
    final leftDate = _asDate(left);
    if (leftDate == null) return false;

    switch (node.predicate) {
      case Predicate.inLastDays:
        final d = _daysFromPresetOrInt(node.value);
        if (d == null) return true; // any time
        final threshold = now.subtract(Duration(days: d));
        return !leftDate.isBefore(_dateOnly(threshold));

      case Predicate.lessThan: {
        final v = _asDate(node.value);
        return (v != null) ? leftDate.isBefore(_dateOnly(v)) : false;
      }
      case Predicate.greaterThan: {
        final v = _asDate(node.value);
        return (v != null) ? leftDate.isAfter(_dateOnly(v)) : false;
      }
      case Predicate.between: {
        final a = _asDate(node.value);
        final b = _asDate(node.value2);
        if (a == null || b == null) return false;
        final from = _dateOnly(a);
        final to = _dateOnly(b);
        return !leftDate.isBefore(from) && !leftDate.isAfter(to);
      }
      default:
        return false;
    }
  }

  // Branch by field type
  final meta = kFieldMeta[node.field];

  switch (meta!.type) {
    case FilterPropType.string: {
      final l = _asString(left);
      var r = _asString(node.value);

      // Owner: allow "me" sentinel
      if (node.field == StudyField.owner && r != null) {
        final rv = r.toLowerCase();
        if (rv == 'me' || rv == '@me') {
          final myStrings = <String>{
            if (meId != null) meId,
            if (meEmail != null) meEmail,
          }.map((e) => e.toLowerCase());

          switch (node.predicate) {
            case Predicate.equals:
              return l != null && myStrings.contains(l.toLowerCase());
            case Predicate.notEquals:
              return l == null || !myStrings.contains(l.toLowerCase());
            case Predicate.contains:
              return l != null && myStrings.any((m) => l.toLowerCase().contains(m));
            default:
              return false;
          }
        }
      }

      switch (node.predicate) {
        case Predicate.equals:
          return _ieq(l, r);
        case Predicate.notEquals:
          return !_ieq(l, r);
        case Predicate.contains:
          return _icontains(l, r);
        default:
          return false;
      }
    }

    case FilterPropType.enumeration: {
      final l = _asString(left);
      final r = _asString(node.value);
      switch (node.predicate) {
        case Predicate.equals:
          return _ieq(l, r);
        case Predicate.notEquals:
          return !_ieq(l, r);
        default:
          return false;
      }
    }

    case FilterPropType.number: {
      final l = _asNum(left);
      switch (node.predicate) {
        case Predicate.equals:
          return l != null && _asNum(node.value) == l;
        case Predicate.notEquals:
          return l != null && _asNum(node.value) != l;
        case Predicate.lessThan: {
          final r = _asNum(node.value);
          return l != null && r != null && l < r;
        }
        case Predicate.greaterThan: {
          final r = _asNum(node.value);
          return l != null && r != null && l > r;
        }
        case Predicate.between: {
          final a = _asNum(node.value);
          final b = _asNum(node.value2);
          if (l == null || a == null || b == null) return false;
          final from = a <= b ? a : b;
          final to   = b >= a ? b : a;
          return l >= from && l <= to;
        }
        default:
          return false;
      }
    }

    case FilterPropType.boolean:
      // already handled via isTrue/isFalse
      return false;

    case FilterPropType.date:
    case FilterPropType.datetime: {
      final ld = _asDate(left);
      if (ld == null) return false;
      switch (node.predicate) {
        case Predicate.lessThan: {
          final rd = _asDate(node.value);
          return (rd != null) ? ld.isBefore(_dateOnly(rd)) : false;
        }
        case Predicate.greaterThan: {
          final rd = _asDate(node.value);
          return (rd != null) ? ld.isAfter(_dateOnly(rd)) : false;
        }
        case Predicate.between: {
          final a = _asDate(node.value);
          final b = _asDate(node.value2);
          if (a == null || b == null) return false;
          final from = _dateOnly(a);
          final to = _dateOnly(b);
          return !ld.isBefore(from) && !ld.isAfter(to);
        }
        default:
          return false;
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Default getters for Study (used by back-compat compileToPredicate)
// ---------------------------------------------------------------------------

Map<StudyField, FieldGetter<Study>> _defaultStudyGetters() {
  Object? _try(dynamic f()) {
    try { return f(); } catch (_) { return null; }
  }

  String? _stringify(Object? v) {
    if (v == null) return null;
    if (v is String) return v;
    final name = _try(() => (v as dynamic).name);
    if (name is String) return name;
    return v.toString();
  }

  DateTime? _asStudyDate(dynamic s) {
    final d = _try(() => s.createdAt) ??
        _try(() => s.creationDate) ??
        _try(() => s.createdOn) ??
        _try(() => s.registry?.createdAt) ??
        _try(() => s.meta?.createdAt);
    if (d is DateTime) return DateTime(d.year, d.month, d.day);
    if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
    if (d is String) return DateTime.tryParse(d);
    return null;
  }

  return {
    StudyField.title: (s) => _stringify(
          _try(() => (s as dynamic).title) ??
          _try(() => (s as dynamic).name) ??
          _try(() => (s as dynamic).studyTitle),
        ),
    StudyField.status: (s) => _stringify(
          _try(() => (s as dynamic).status) ??
          _try(() => (s as dynamic).studyStatus) ??
          _try(() => (s as dynamic).registry?.status),
        ),
    StudyField.owner: (s) => _stringify(
          _try(() => (s as dynamic).ownerEmail) ??
          _try(() => (s as dynamic).ownerId) ??
          _try(() => (s as dynamic).owner?.email) ??
          _try(() => (s as dynamic).createdBy?.email) ??
          _try(() => (s as dynamic).author?.email) ??
          _try(() => (s as dynamic).ownerName),
        ),
    StudyField.createdAt: (s) => _asStudyDate(s),
    StudyField.resultSharing: (s) => _stringify(
          _try(() => (s as dynamic).resultSharing) ??
          _try(() => (s as dynamic).results?.sharingPolicy) ??
          _try(() => (s as dynamic).sharing),
        ),
    StudyField.registryPublished: (s) {
      final v = _try(() => (s as dynamic).registryPublished) ??
          _try(() => (s as dynamic).registry?.published) ??
          _try(() => (s as dynamic).isPublished) ??
          _try(() => (s as dynamic).published);
      if (v is bool) return v;
      if (v is String) {
        final t = v.toLowerCase().trim();
        if (t == 'true' || t == '1' || t == 'yes') return true;
        if (t == 'false' || t == '0' || t == 'no') return false;
      }
      if (v is num) return v != 0;
      return null;
    },
    StudyField.participation: (s) {
      final v = _try(() => (s as dynamic).participantsCount) ??
          _try(() => (s as dynamic).enrolledParticipants) ??
          _try(() => (s as dynamic).participationCount) ??
          _try(() => (s as dynamic).metrics?.participants);
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    },
    StudyField.totalMissedDays: (s) {
      final v = _try(() => (s as dynamic).totalMissedDays) ??
          _try(() => (s as dynamic).metrics?.missedDays);
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    },
  };
}

// ---------------------------------------------------------------------------
// Conversions & helpers
// ---------------------------------------------------------------------------

bool _ieq(String? a, String? b) {
  if (a == null || b == null) return false;
  return a.toLowerCase() == b.toLowerCase();
}

bool _icontains(String? haystack, String? needle) {
  if (haystack == null || needle == null) return false;
  return haystack.toLowerCase().contains(needle.toLowerCase());
}

String? _asString(Object? v) {
  if (v == null) return null;
  if (v is String) return v;
  final name = _tryOrNull(() => (v as dynamic).name);
  if (name is String) return name;
  return v.toString();
}

num? _asNum(Object? v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

bool? _asBool(Object? v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is String) {
    final s = v.toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
  }
  if (v is num) return v != 0;
  return null;
}

DateTime? _asDate(Object? v) {
  if (v == null) return null;
  if (v is DateTime) return DateTime(v.year, v.month, v.day);
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) {
    final iso = DateTime.tryParse(v);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);
    final parts = v.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) return DateTime(y, m, d);
    }
  }
  return null;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

int? _daysFromPresetOrInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);

  if (v is CreatedAtPreset) {
    switch (v) {
      case CreatedAtPreset.any:
        return null;
      case CreatedAtPreset.last7d:
        return 7;
      case CreatedAtPreset.last30d:
        return 30;
      case CreatedAtPreset.last90d:
        return 90;
      case CreatedAtPreset.last180d:
        return 180;
      case CreatedAtPreset.customRange:
        return null; // handled via BETWEEN
    }
  }
  return null;
}

Object? _tryOrNull(Object? Function() fn) {
  try { return fn(); } catch (_) { return null; }
}
