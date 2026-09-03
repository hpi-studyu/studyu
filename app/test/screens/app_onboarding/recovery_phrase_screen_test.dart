import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/app_onboarding/recovery_phrase_screen.dart';

Widget _wrap(Widget child) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  locale: const Locale('en'),
  home: child,
);

void main() {
  testWidgets('reveals the recovery phrase and its save confirmation on demand', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const RecoveryPhraseScreen(initialPhrase: ['first', 'second'])),
    );

    expect(find.text('Show Recovery Phrase'), findsOneWidget);
    expect(find.text('first'), findsNothing);
    expect(
      find.text(
        'I have saved all 13 words in a safe place and can retrieve them when I want to restore my account. I can also view them again in Study Settings.',
      ),
      findsNothing,
    );

    await tester.tap(find.text('Show Recovery Phrase'));
    await tester.pumpAndSettle();

    expect(find.text('first\nsecond'), findsOneWidget);
    expect(
      find.text(
        'I have saved all 13 words in a safe place and can retrieve them when I want to restore my account. I can also view them again in Study Settings.',
      ),
      findsOneWidget,
    );
    expect(find.byType(CheckboxListTile), findsOneWidget);

    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Next'))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Next'))
          .onPressed,
      isNotNull,
    );
  });
}
