import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/dashboard/settings.dart';
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
    RestoreAccountService.debugResetRecoveryIdGetterForTesting();
    RestoreAccountService.debugResetRecoveryIdRotatorForTesting();
  });

  testWidgets('retries after recovery phrase loading fails', (tester) async {
    final key = GlobalKey<RecoveryPhraseContentState>();
    var requestCount = 0;
    RestoreAccountService.debugCurrentUserIdGetterForTesting = () => 'user';
    RestoreAccountService.debugRecoveryIdGetterForTesting = () async {
      requestCount++;
      return requestCount == 1 ? null : '00000000-0000-0000-0000-000000000002';
    };

    await tester.pumpWidget(_wrap(RecoveryPhraseContent(key: key)));
    await tester.pumpAndSettle();

    expect(key.currentState!.hasError, isTrue);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(requestCount, 2);
    expect(key.currentState!.hasError, isFalse);
    expect(key.currentState!.phrase, isNotNull);
  });

  testWidgets('loads the phrase only after Settings recovery section expands', (
    tester,
  ) async {
    var requestCount = 0;
    final expectedPhrase = encode(BigInt.two);
    RestoreAccountService.debugCurrentUserIdGetterForTesting = () => 'user';
    RestoreAccountService.debugRecoveryIdGetterForTesting = () async {
      requestCount++;
      return '00000000-0000-0000-0000-000000000002';
    };

    await tester.pumpWidget(_wrap(const RecoveryPhraseWidget()));
    await tester.pumpAndSettle();

    expect(requestCount, 0);
    expect(find.text(expectedPhrase.first), findsNothing);

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(requestCount, 1);
    expect(find.byType(Chip), findsNWidgets(expectedPhrase.length));
  });

  testWidgets('copies the recovery phrase in its displayed order', (
    tester,
  ) async {
    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardText =
              (call.arguments as Map<Object?, Object?>)['text']! as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    const phrase = ['first', 'second', 'third'];

    await tester.pumpWidget(
      _wrap(
        const RecoveryPhraseContent(
          initialPhrase: phrase,
          showConfirmation: false,
          showRotation: false,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Copy'));
    await tester.tap(find.text('Copy'));
    await tester.pump();

    expect(clipboardText, 'first second third');
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
    var rotationCount = 0;
    RestoreAccountService.debugRecoveryIdRotatorForTesting = () async {
      rotationCount++;
      return '00000000-0000-0000-0000-000000000002';
    };
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

    expect(rotationCount, 1);
    expect(find.text(newPhrase), findsOneWidget);
    expect(
      find.text('A new recovery phrase has been issued. Save it now.'),
      findsOneWidget,
    );
  });
}
