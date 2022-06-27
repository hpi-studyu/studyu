import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum StudiesFilter {
  all,
  owned,
  shared
}

extension StudiesFilterByUser on StudiesFilter {
  Iterable<Study> apply({required Iterable<Study> studies, required User user}) {
    switch (this) {
      case StudiesFilter.all:
        return studies;
      case StudiesFilter.owned:
        return studies.where((s) => s.isOwner(user));
      case StudiesFilter.shared:
        return studies.where((s) => s.isEditor(user));
    }
  }
}
