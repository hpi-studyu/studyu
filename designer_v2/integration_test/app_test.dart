// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:integration_test/integration_test.dart';
import 'package:studyu_designer_v2/features/app.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';

import 'robots/robots.dart';

void main() {
  late SharedPreferences sharedPreferences;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadEnv();
    await runAsync(prefetchEmojiFont);
    // Turn off the # in the URLs on the web
    usePathUrlStrategy();
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  });

  group('end-to-end tests', () {
    // NOTE:
    //  the hydration of user is inconsistent and derails the tests
    //  thus, we need to clear the sharedPreferences so that the
    //  hydration does not happen
    // When 'Remember me is added, this method can be removed - but
    //  it could be a good practice to keep it so that the test instances
    //  do not share any information in the app cache
    setUp(() async => await sharedPreferences.clear()); // RM

    patrolWidgetTest('Sign up -> Sign out flow test', ($) async {
      final appRobot = AppRobot($);
      final authRobot = AuthRobot($);
      final studiesRobot = StudiesRobot($);

      await $.pumpWidgetAndSettle(ProviderScope(overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ], child: const App()));
      await appRobot.validateOnLoginScreen();
      await authRobot.navigateToSignUpScreen();
      await authRobot.enterEmail('test@email.com');
      await authRobot.enterPassword('password');
      await authRobot.enterPasswordConfirmation('password');
      await authRobot.tapTermsCheckbox();
      await authRobot.tapSignUpButton();

      await studiesRobot.validateOnStudiesScreen();
      await studiesRobot.tapSignOutButton();

      await appRobot.validateOnLoginScreen();
    });

    patrolWidgetTest('Sign in test', ($) async {
      final appRobot = AppRobot($);
      final authRobot = AuthRobot($);
      final studiesRobot = StudiesRobot($);

      await $.pumpWidgetAndSettle(ProviderScope(overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ], child: const App()));
      await appRobot.validateOnLoginScreen();
      await authRobot.enterEmail('test@email.com');
      await authRobot.enterPassword('password');
      await authRobot.tapSignInButton();

      await studiesRobot.validateOnStudiesScreen();
      await studiesRobot.tapSignOutButton(); // RM
    });

    /* NOTE: 
        * remove skip value when remember me is implemented
        * also remove all lines marked by RM
       The hope is that the Session key will persist across test app instances
       and the user will stay logged in 
    */
    patrolWidgetTest('Remember me function test', skip: true, ($) async {
      final studiesRobot = StudiesRobot($);

      await $.pumpWidgetAndSettle(ProviderScope(overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ], child: const App()));

      studiesRobot.validateOnStudiesScreen();
    });

    patrolWidgetTest('Create a study/rename it test', ($) async {
      final appRobot = AppRobot($); // RM
      final authRobot = AuthRobot($); // RM
      final studiesRobot = StudiesRobot($);
      final studyDesignRobot = StudyDesignRobot($);
      final studyInfoRobot = StudyInfoRobot($);

      await $.pumpWidgetAndSettle(ProviderScope(overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ], child: const App()));
      await appRobot.validateOnLoginScreen(); // RM
      await authRobot.enterEmail('test@email.com'); // RM
      await authRobot.enterPassword('password'); // RM
      await authRobot.tapSignInButton(); // RM

      await studiesRobot.validateNoStudiesFound();
      await studiesRobot.tapNewStudyButton();

      await studyDesignRobot.validateOnDesignScreen();
      await studyInfoRobot.validateOnStudyInfoScreen();
      await studyInfoRobot.enterStudyName('Test Study');

      await studyDesignRobot.validateChangesSaved();
      await studyDesignRobot.tapLeftDrawerButton();
      await studyDesignRobot.tapMyStudiesButton();

      await studiesRobot.validateOnStudiesScreen();
      await studiesRobot.validateStudyDraftExists();

      await studiesRobot.tapSignOutButton(); // RM
    });

    patrolWidgetTest('Publish a study test', ($) async {
      final appRobot = AppRobot($); // RM
      final authRobot = AuthRobot($); // RM
      final studiesRobot = StudiesRobot($);
      final studyDesignRobot = StudyDesignRobot($);
      final studyInfoRobot = StudyInfoRobot($);
      final studyInterventionsRobot = StudyInterventionsRobot($);
      final studyMeasurementsRobot = StudyMeasurementsRobot($);

      await $.pumpWidgetAndSettle(ProviderScope(overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ], child: const App()));
      await appRobot.validateOnLoginScreen(); // RM
      await authRobot.enterEmail('test@email.com'); // RM
      await authRobot.enterPassword('password'); // RM
      await authRobot.tapSignInButton(); // RM

      await studiesRobot.validateOnStudiesScreen();
      await studiesRobot.validateStudyDraftExists();
      await studiesRobot.tapOnExistingStudy();

      await studyDesignRobot.validateOnDesignScreen();

      await studyInfoRobot.validateOnStudyInfoScreen();
      await studyInfoRobot.enterStudyDescription('Test study description');
      await studyInfoRobot.enterResponsibleOrg('Test Organization, Inc.');
      await studyInfoRobot.enterInstitutionalReviewBoard('IRB of Test Organization, Inc.');
      await studyInfoRobot.enterIRBProtocolNumber('456-112-324');
      await studyInfoRobot.enterResponsiblePerson('Test First Name, Test Last Name');
      await studyInfoRobot.enterWebsite('test-study.org');
      await studyInfoRobot.enterContactEmail('test@email.com');
      await studyInfoRobot.enterContactPhone('+491112221122');
      await studyDesignRobot.validateChangesSaved();

      await studyDesignRobot.navigateToParticipationScreen();
      // NO-OP because exception in participation screening questionnare:
      //
      // TODO: add participation questionnare testing

      await studyDesignRobot.navigateToInterventionsScreen();
      // Repeat twice for two interventions
      await studyInterventionsRobot.tapAddInterventionButton();
      await studyInterventionsRobot.enterInterventionName('Test Intervention A');
      await studyInterventionsRobot.enterInterventionDesciption('Test Intervention Description A');
      await studyInterventionsRobot.tapAddInterventionTaskButton();
      await studyInterventionsRobot.enterInterventionTaskName('Task 1A');
      await studyInterventionsRobot.enterInterventionTaskDescription('Task 1A Description');
      await studyInterventionsRobot.tapSaveInterventionTaskButton();
      await studyInterventionsRobot.tapSaveInterventionButton();

      await studyInterventionsRobot.tapAddInterventionButton();
      await studyInterventionsRobot.enterInterventionName('Test Intervention B');
      await studyInterventionsRobot.enterInterventionDesciption('Test Intervention Description B');
      await studyInterventionsRobot.tapAddInterventionTaskButton();
      await studyInterventionsRobot.enterInterventionTaskName('Task 1B');
      await studyInterventionsRobot.enterInterventionTaskDescription('Task 1B Description');
      await studyInterventionsRobot.tapSaveInterventionTaskButton();
      await studyInterventionsRobot.tapSaveInterventionButton();

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

      await studyDesignRobot.tapPublishButton();
      await studyDesignRobot.tapConfirmPublishButton();
      await studyDesignRobot.tapSkipForNowButton();
      await studyDesignRobot.validateStudyPublished();

      await studyDesignRobot.tapLeftDrawerButton();
      await studyDesignRobot.tapMyStudiesButton();

      await studiesRobot.validateOnStudiesScreen();
      await studiesRobot.validateStudyPublished();

      await studiesRobot.tapSignOutButton(); // RM
    });
  });
}
