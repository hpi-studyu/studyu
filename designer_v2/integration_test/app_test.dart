// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/app.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';
import 'package:flutter/rendering.dart';

void main() {
  late SharedPreferences sharedPreferences;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    debugRepaintRainbowEnabled = true;
    await loadEnv();
    await runAsync(prefetchEmojiFont);
    // Turn off the # in the URLs on the web
    usePathUrlStrategy();
    sharedPreferences = await SharedPreferences.getInstance();
  });

  group('end-to-end tests', () {
    testWidgets('Start and splash screen', (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)], child: const App()));
      await tester.pump();
      // Check if we see the splash screen
      expect(find.text('Loading...'), findsOneWidget);
      await tester.pump();
      // Make sure we are loaded properly
      expect(find.text('Learn'), findsOneWidget);
      print('Pass 1');
    });
    testWidgets('Sign up -> Sign out flow test', (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)], child: const App()));
      await tester.pump();
      // Check if we see the splash screen
      expect(find.text('Loading...'), findsOneWidget);
      await tester.pump();
      // Make sure we are loaded properly
      expect(find.text('Learn'), findsOneWidget);
      // Move to the sign up page
      await tester.tap(find.text('Sign up'));
      await tester.pump();
      // Enter details into the appropriate form fields
      await tester.enterText(find.widgetWithText(ReactiveTextField, 'Email'), 'test@email.com');
      await tester.pump();
      await tester.enterText(find.widgetWithText(ReactiveTextField, 'Password'), 'password');
      await tester.pump();
      await tester.enterText(find.widgetWithText(ReactiveTextField, 'Confirm password'), 'password');
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      // Tap on the sign up button and wait for the home screen to appear
      await tester.runAsync(() => tester.tap(find.text('Create account')));
      await tester.pump();
      // Check if the homescreen has appeared
      expect(find.text('My Studies'), findsWidgets);
      // Wait until the API call returns
      await tester.pump(const Duration(seconds: 1));
      // Click the sign out button
      await tester.tap(find.text('Sign out'));
      await tester.pump();
      // Check if we are back on the auth screen
      expect(find.text('Learn'), findsOneWidget);
      print('Pass 2');
    });
    testWidgets('Sign in -> Sign out flow test', (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)], child: const App()));
      await tester.pump();
      // Check if we see the splash screen
      expect(find.text('Loading...'), findsOneWidget);
      await tester.pump();
      // Make sure we are loaded properly
      expect(find.text('Learn'), findsOneWidget);
       // Enter details into the appropriate form fields
      await tester.enterText(find.widgetWithText(ReactiveTextField, 'Email'), 'test@email.com');
      await tester.pump();
      await tester.enterText(find.widgetWithText(ReactiveTextField, 'Password'), 'password');
      await tester.pump();
      // Tap on the sign up button and wait for the home screen to appear
      await tester.runAsync(() => tester.tap(find.text('Sign in')));
      await tester.pump();
      // Check if the homescreen has appeared
      expect(find.text('My Studies'), findsWidgets);
      // Wait until the API call returns
      await tester.pump(const Duration(seconds: 1));
      // Click the sign out button
      await tester.tap(find.text('Sign out'));
      await tester.pump();
      // Check if we are back on the auth screen
      expect(find.text('Learn'), findsOneWidget);
      print('Pass 3');
    }); 
  });
}