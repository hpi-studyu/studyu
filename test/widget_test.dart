// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:Nof1/util/localization.dart';
import 'package:Nof1/welcome/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget setup(Widget child) {
  return MaterialApp(
    localizationsDelegates: [
      Nof1LocalizationsDelegate(testing: true),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  testWidgets('Counter increments smoke test', (tester) async {
    await tester.pumpWidget(setup(WelcomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('get_started'), findsOneWidget);
  });
}
