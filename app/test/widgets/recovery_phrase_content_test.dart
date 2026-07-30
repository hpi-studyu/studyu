import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/recovery_phrase_content.dart';

Widget _wrap(Widget child) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  locale: const Locale('en'),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('hides copy and download feedback when disabled', (tester) async {
    const channel = MethodChannel('flutter_file_dialog');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) async => 'saved',
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );

    await tester.pumpWidget(
      _wrap(
        const RecoveryPhraseContent(
          initialPhrase: ['word'],
          showConfirmation: false,
          showSuccessFeedback: false,
        ),
      ),
    );

    for (final label in ['Copy', 'Download']) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    }
  });

  testWidgets('shows copy feedback by default', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const RecoveryPhraseContent(
          initialPhrase: ['word'],
          showConfirmation: false,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Copy'));
    await tester.tap(find.text('Copy'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
