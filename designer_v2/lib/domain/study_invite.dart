import 'package:studyu_core/core.dart';

extension StudyInviteX on StudyInvite {
  bool get hasPreconfiguredSchedule =>
      preselectedInterventionIds != null &&
      preselectedInterventionIds!.isNotEmpty;
}
