// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/app_onboarding/welcome.dart';

Widget setup(Widget child) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: Locale('en'),
    home: child,
  );
}

void main() {
  testWidgets('Counter increments smoke test', (tester) async {
    await tester.pumpWidget(setup(WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
  });
}
