import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_core/core.dart';

class AppState {
  Study selectedStudy;
  List<Intervention> selectedInterventions;
  StudySubject activeSubject;
  String inviteCode;
  List<String> preselectedInterventionIds;
  StudyNotifications studyNotifications;

  AppState();
}
