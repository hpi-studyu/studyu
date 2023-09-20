// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:studyu_designer_v2/features/app.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';

import 'robots/app_robot.dart';
import 'robots/auth_robot.dart';
import 'robots/studies_robot.dart';

void main() {
  late SharedPreferences sharedPreferences;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadEnv();
    await runAsync(prefetchEmojiFont);
    // Turn off the # in the URLs on the web
    usePathUrlStrategy();
    sharedPreferences = await SharedPreferences.getInstance();
  });

  group('end-to-end tests', () {
    testWidgets('Start and splash screen', (tester) async {
      final appRobot = AppRobot(tester);

      await tester.pumpWidget(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)], child: const App()));
      await tester.pump();
      await appRobot.validateOnSplashScreen();
      await tester.pump();
      await appRobot.validateOnAuthScreen();
    });
    testWidgets('Sign up -> Sign out flow test', (tester) async {
      final appRobot = AppRobot(tester);
      final authRobot = AuthRobot(tester);
      final studiesRobot = StudiesRobot(tester);

      await tester.pumpWidget(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)], child: const App()));
      await tester.pump();
      await appRobot.validateOnSplashScreen();
      await tester.pump();
      await appRobot.validateOnAuthScreen();
      await authRobot.navigateToSignUpScreen();
      await tester.pump();
      await authRobot.enterEmail('test@email.com');
      await tester.pump();
      await authRobot.enterPassword('password');
      await tester.pump();
      await authRobot.enterPasswordConfirmation('password');
      await tester.pump();
      await authRobot.tapTermsCheckbox();
      await tester.pump();
      await authRobot.tapSignUpButton();
      await tester.pump(const Duration(seconds: 3));
      await studiesRobot.validateOnStudiesScreen();
      await studiesRobot.tapSignOutButton();
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await appRobot.validateOnAuthScreen();
    });
    testWidgets('Sign in -> Sign out flow test', (tester) async {
      final appRobot = AppRobot(tester);
      final authRobot = AuthRobot(tester);
      final studiesRobot = StudiesRobot(tester);

      await tester.pumpWidget(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)], child: const App()));
      await tester.pump();
      appRobot.validateOnSplashScreen();
      await tester.pump();
      appRobot.validateOnAuthScreen();
      authRobot.enterEmail('test@email.com');
      await tester.pump();
      authRobot.enterPassword('password');
      await tester.pump();
      await authRobot.tapSignInButton();
      await tester.pump(const Duration(seconds: 3));
      await studiesRobot.validateOnStudiesScreen();
      await studiesRobot.tapSignOutButton();
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await appRobot.validateOnAuthScreen();
    });
  });
}