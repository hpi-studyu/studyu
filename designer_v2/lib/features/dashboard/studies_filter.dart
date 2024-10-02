import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/routing/router_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum StudiesFilter with GoRouteParamEnum {
  all,
  owned,
  shared,
  public,
  standalone,
  template,
  substudy,
  live,
  draft,
  closed,
  inviteOnly,
  everyone
}

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
      case StudiesFilter.standalone:
        return studies.where((s) => s.type == StudyType.standalone).toList();
      case StudiesFilter.template:
        return studies.where((s) => s.type == StudyType.template).toList();
      case StudiesFilter.substudy:
        return studies.where((s) => s.type == StudyType.subStudy).toList();
      case StudiesFilter.live:
        return studies.where((s) => s.status == StudyStatus.running).toList();
      case StudiesFilter.draft:
        return studies.where((s) => s.status == StudyStatus.draft).toList();
      case StudiesFilter.closed:
        return studies.where((s) => s.status == StudyStatus.closed).toList();
      case StudiesFilter.inviteOnly:
        return studies
            .where((s) => s.participation == Participation.invite)
            .toList();
      case StudiesFilter.everyone:
        return studies
            .where((s) => s.participation == Participation.open)
            .toList();
    }
  }
}
