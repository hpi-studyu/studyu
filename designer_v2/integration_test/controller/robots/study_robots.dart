import 'package:patrol_finders/patrol_finders.dart';

import 'robots.dart';

abstract class StudyRobots {
  final PatrolTester $;
  final AppRobot appRobot;
  final AuthRobot authRobot;
  final StudiesRobot studiesRobot;
  final StudyDesignRobot studyDesignRobot;
  final StudyInfoRobot studyInfoRobot;
  final StudyInterventionsRobot studyInterventionsRobot;
  final StudyMeasurementsRobot studyMeasurementsRobot;

  StudyRobots(this.$)
      : appRobot = AppRobot($),
        authRobot = AuthRobot($),
        studiesRobot = StudiesRobot($),
        studyDesignRobot = StudyDesignRobot($),
        studyInfoRobot = StudyInfoRobot($),
        studyInterventionsRobot = StudyInterventionsRobot($),
        studyMeasurementsRobot = StudyMeasurementsRobot($);
}
