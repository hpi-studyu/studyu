import 'package:patrol_finders/src/custom_finders/patrol_tester.dart';
import 'package:studyu_core/src/env/env.dart' as env;

import '../mockup/mockup_studies.dart';
import 'study_base_test.dart';

class Test1 extends StudyBaseTest {
  Test1.go(PatrolTester $) : super.go($, MockupStudies.study1);

  @override
  Future<void> execute(String email, String password) async {
    if (randomTest) {
      // START SIGN UP
      await authRobot.navigateToSignUpScreen();
      await authRobot.enterEmail(email);
      await authRobot.enterPassword(password);
      await authRobot.enterPasswordConfirmation(password);
      await authRobot.tapTermsCheckbox();
      await authRobot.tapSignUpButton();
      await studiesRobot.tapSignOutButton();
      // FINISH SIGN UP
    }

    // START SIGN IN
    await authRobot.enterEmail(email);
    await authRobot.enterPassword(password);
    await authRobot.tapSignInButton();
    // FINISH SIGN IN

    print('User signed in');

    // UserID is only available after login
    controller.init(env.client.auth.currentUser!.id);

    print("Controller created");

    // START CREATE STUDY
    await studiesRobot.tapNewStudyButton();

    await controller.fillTitle();

    print("Title filled");

    await studyDesignRobot.tapLeftDrawerButton();
    await studyDesignRobot.tapMyStudiesButton();
    // FINISH CREATE STUDY

    print("Study created");

    // START FILL AND PUBLISH STUDY
    // todo specify the exact study that should be tapped by name
    await studiesRobot.tapOnExistingStudy();

    await controller.fillInfoPage();

    print("Info page filled");

    await studyDesignRobot.navigateToParticipationScreen();
    // todo implement participation screen tests

    await studyDesignRobot.navigateToInterventionsScreen();

    // Create interventions
    await controller
        .fillInterventions((interventionList) => [interventionList.first]);
    await controller
        .fillInterventions((interventionList) => [interventionList.last]);

    await studyDesignRobot.navigateToMeasurementsScreen();

    await controller.fillObservations((observationList) => observationList);

    await studyDesignRobot.tapPublishButton();
    await studyDesignRobot.tapConfirmPublishButton();
    await studyDesignRobot.tapSkipForNowButton();
    await studyDesignRobot.validateStudyPublished();
    // FINISH FILL AND PUBLISH STUDY

    await studyDesignRobot.tapLeftDrawerButton();
    await studyDesignRobot.tapMyStudiesButton();
  }
}
