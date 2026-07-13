import 'package:studyu_core/core.dart';

enum InviteCodesSortColumn { code, enrolled, createdAt, updatedAt }

extension StudyInviteX on StudyInvite {
  bool get hasPreconfiguredSchedule =>
      preselectedInterventionIds != null &&
      preselectedInterventionIds!.isNotEmpty;
}
