import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/app_onboarding/rejoin_study_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: child,
  );
}

void main() {
  testWidgets('disables restore when recovery phrase has too many words', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const RejoinStudyScreen()));

    await tester.enterText(
      find.byType(TextFormField),
      'one two three four five six seven eight nine ten eleven twelve thirteen fourteen',
    );
    await tester.pump();

    expect(
      find.text(
        'Recovery phrases have 13 words. Remove extra words to continue.',
      ),
      findsWidgets,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Restore account'),
          )
          .onPressed,
      isNull,
    );
  });
}
