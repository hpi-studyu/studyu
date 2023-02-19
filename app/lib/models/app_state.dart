import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_core/core.dart';

class AppState with ChangeNotifier {
  Study selectedStudy;
  List<Intervention> selectedInterventions;
  StudySubject activeSubject;
  String inviteCode;
  List<String> preselectedInterventionIds;
  StudyNotifications studyNotifications;
  bool isPreview = false;

  /// Flag indicating whether the participant's progress should be tracked
  ///
  /// We always track the participant's progress except when the study is
  /// being viewed in test/preview mode while already launched (to avoid
  /// mixing results from test users with actual participants)
  bool get trackParticipantProgress => !(isPreview && selectedStudy.isRunning);

  AppState();

  Future selectNotification(String taskId) async {
    if (taskId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskScreen(
            task: null,
            taskId: taskId,
          ),
        ),
      );
    }
  }

  void updateStudy(Study study) {
    // todo baseline
    study.schedule.includeBaseline = false;
    selectedStudy = study;
    if (activeSubject.study.id == study.id) {
      activeSubject.study = study;
    }
    notifyListeners();
  }
}
