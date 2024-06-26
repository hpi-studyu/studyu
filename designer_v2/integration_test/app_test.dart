// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:studyu_designer_v2/features/app.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'robots/robots.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadEnv();
    await runAsync(prefetchEmojiFont);
    // Turn off the # in the URLs on the web
    usePathUrlStrategy();
    await SecureStorage.deleteAll();
  });

  group('Test all', () {
    const randomTest = true;
    final email = randomTest
        ? '${DateTime.now().millisecondsSinceEpoch}@studyu.health'
        : 'test@studyu.health';
    const password = 'password';

    patrolWidgetTest('TestAll', (PatrolTester $) async {
      final authRobot = AuthRobot($);
      final studiesRobot = StudiesRobot($);
      final studyDesignRobot = StudyDesignRobot($);
      final studyInfoRobot = StudyInfoRobot($);
      final studyInterventionsRobot = StudyInterventionsRobot($);
      final studyMeasurementsRobot = StudyMeasurementsRobot($);

      await $.pumpWidgetAndSettle(
        const ExcludeSemantics(child: ProviderScope(child: App())),
      );

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

      // START CREATE STUDY
      await studiesRobot.tapNewStudyButton();

      await studyInfoRobot.enterStudyName('Publish Test Study');

      await $.pump(const Duration(milliseconds: 1500));

      await studyDesignRobot.validateChangesSaved();
      await studyDesignRobot.tapLeftDrawerButton();
      await studyDesignRobot.tapMyStudiesButton();
      // FINISH CREATE STUDY

      // START FILL AND PUBLISH STUDY
      // todo specify the exact study that should be tapped by name
      await studiesRobot.tapOnExistingStudy();

      await studyInfoRobot.enterStudyDescription('Test study description');
      await studyInfoRobot.enterResponsibleOrg('Test Organization, Inc.');
      await studyInfoRobot
          .enterInstitutionalReviewBoard('IRB of Test Organization, Inc.');
      await studyInfoRobot.enterIRBProtocolNumber('456-112-324');
      await studyInfoRobot
          .enterResponsiblePerson('Test First Name, Test Last Name');
      await studyInfoRobot.enterWebsite('test-study.org');
      await studyInfoRobot.enterContactEmail('test@email.com');
      await studyInfoRobot.enterContactPhone('+491112221122');
      await studyDesignRobot.validateChangesSaved();

      await studyDesignRobot.navigateToParticipationScreen();
      // NO-OP because exception in participation screening questionnaire

      await studyDesignRobot.navigateToInterventionsScreen();

      // Create two interventions
      await studyInterventionsRobot.createIntervention(
        interventionName: 'Test Intervention A',
        interventionDescription: 'Test Intervention Description A',
        taskName: 'Task 1A',
        taskDescription: 'Task 1A Description',
      );

      await studyDesignRobot.validateChangesSaved();

      await studyInterventionsRobot.createIntervention(
        interventionName: 'Test Intervention B',
        interventionDescription: 'Test Intervention Description B',
        taskName: 'Task 1B',
        taskDescription: 'Task 1B Description',
      );

      await studyDesignRobot.navigateToMeasurementsScreen();
      await studyMeasurementsRobot.tapAddSurveyButton();
      await studyMeasurementsRobot.enterSurveyName('Test Survey');
      await studyMeasurementsRobot.enterSurveyIntroText('Test Intro');
      await studyMeasurementsRobot.enterSurveyOutroText('Test Outro');
      await studyMeasurementsRobot.tapAddSurveyQuestionButton();
      await studyMeasurementsRobot.enterSurveyQuestionText('Test Question');
      await studyMeasurementsRobot.enterSurveyQuestionOption1('Test Option 1');
      await studyMeasurementsRobot.enterSurveyQuestionOption2('Test Option 2');
      await studyMeasurementsRobot.tapSaveSurveyQuestionButton();
      await studyMeasurementsRobot.tapSaveSurveyButton();
      await studyDesignRobot.validateChangesSaved();

      await studyDesignRobot.tapPublishButton();
      await studyDesignRobot.tapConfirmPublishButton();
      await studyDesignRobot.tapSkipForNowButton();
      await studyDesignRobot.validateStudyPublished();
      // FINISH FILL AND PUBLISH STUDY

      await studyDesignRobot.tapLeftDrawerButton();
      await studyDesignRobot.tapMyStudiesButton();

      /*env.client.from('study').select().then((value) {
        print(value);
        // todo parse and validate
      });*/

      //await studiesRobot.tapSignOutButton();
    });
  });
}
