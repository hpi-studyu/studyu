import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/main.dart' as app;
import 'package:studyu_core/core.dart';

const activeRecoveryId = '00000000-0000-4000-8000-000000000010';
const noStudyRecoveryId = '00000000-0000-4000-8000-000000000020';
const confirmationRecoveryId = '00000000-0000-4000-8000-000000000030';

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  // Network/auth navigation includes timers that make pumpAndSettle unsuitable
  // for the production app. Pump only until the expected production UI appears.
  for (var i = 0; i < 60; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(finder, findsWidgets);
}

Future<void> waitForAbsent(WidgetTester tester, Finder finder) async {
  // Dialog routes stay mounted while their exit animation runs. Wait until the
  // dialog leaves the tree before interacting with the screen underneath, so
  // taps cannot land on the departing dialog or its barrier.
  for (var i = 0; i < 60; i++) {
    if (finder.evaluate().isEmpty) return;
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(finder, findsNothing);
}

Future<void> launchCleanApp(WidgetTester tester) async {
  await app.main();
  await waitFor(tester, find.byKey(const ValueKey('welcome_restore_account')));
}

String phraseFor(String uuid) =>
    encode(BigInt.parse(uuid.replaceAll('-', ''), radix: 16)).join(' ');

Future<void> openRestoreAccount(WidgetTester tester) async {
  final restore = find.byKey(const ValueKey('welcome_restore_account'));
  expect(restore, findsOneWidget);
  await tester.tap(restore);
  await waitFor(tester, find.byType(TextFormField));
}

Future<void> submitPhrase(WidgetTester tester, String uuid) async {
  await tester.enterText(find.byType(TextFormField), phraseFor(uuid));
  await tester.pump();
  await tester.tap(find.text('Restore account').last);
}
