import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/widgets/recovery_phrase_content.dart';
import 'package:studyu_core/core.dart';

Widget _wrap(Widget child) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  locale: const Locale('en'),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  tearDown(() {
    RestoreAccountService.clearCache();
    RestoreAccountService.debugResetCurrentUserIdGetterForTesting();
    RestoreAccountService.debugResetRecoveryIdRotatorForTesting();
  });

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

  testWidgets('canceling rotation makes no RPC', (tester) async {
    var rotationCount = 0;
    RestoreAccountService.debugRecoveryIdRotatorForTesting = () async {
      rotationCount++;
      return '00000000-0000-0000-0000-000000000002';
    };

    await tester.pumpWidget(
      _wrap(
        const RecoveryPhraseContent(
          initialPhrase: ['old'],
          showConfirmation: false,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Reissue recovery phrase'));
    await tester.tap(find.text('Reissue recovery phrase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(rotationCount, 0);
  });

  testWidgets('rotation confirmation stays disabled until acknowledged', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const RecoveryPhraseContent(
          initialPhrase: ['old'],
          showConfirmation: false,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Reissue recovery phrase'));
    await tester.tap(find.text('Reissue recovery phrase'));
    await tester.pumpAndSettle();

    final confirmButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Reissue phrase'),
    );
    expect(confirmButton.onPressed, isNull);
  });

  testWidgets('acknowledged confirmation rotates and updates the phrase', (
    tester,
  ) async {
    RestoreAccountService.debugCurrentUserIdGetterForTesting = () => 'user';
    RestoreAccountService.debugRecoveryIdRotatorForTesting = () async =>
        '00000000-0000-0000-0000-000000000002';
    final newPhrase = encode(BigInt.two).join('\n');

    await tester.pumpWidget(
      _wrap(
        const RecoveryPhraseContent(
          initialPhrase: ['old'],
          showConfirmation: false,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Reissue recovery phrase'));
    await tester.tap(find.text('Reissue recovery phrase'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Reissue phrase'));
    await tester.pumpAndSettle();

    expect(find.text(newPhrase), findsOneWidget);
    expect(
      find.text('A new recovery phrase has been issued. Save it now.'),
      findsOneWidget,
    );
  });
}
