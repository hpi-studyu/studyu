import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/routing/router_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum StudiesFilter with GoRouteParamEnum { all, owned, shared, public }

extension StudiesFilterByUser on StudiesFilter {
  Iterable<Study> apply({
    required Iterable<Study> studies,
    required User user,
  }) {
    switch (this) {
      case StudiesFilter.all:
        return studies;
      case StudiesFilter.owned:
        return studies.where((s) => s.isOwner(user));
      case StudiesFilter.shared:
        return studies.where((s) => s.isEditor(user));
      case StudiesFilter.public:
        // show studies published to registry irrespective of their status
        return studies.where(
          (s) => s.registryPublished || s.resultSharing == ResultSharing.public,
        );
    }
  }
}