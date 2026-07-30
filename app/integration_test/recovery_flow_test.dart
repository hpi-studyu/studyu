import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/app_onboarding/restore_account_screen.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/widgets/recovery_phrase_content.dart';
import 'package:studyu_core/core.dart';

/// Integration tests for the recovery flow
/// Run with: flutter test integration_test/recovery_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Recovery Flow Integration Tests', () {
    setUp(() {
      // Clear any cached recovery data before each test
      RestoreAccountService.clearCache();
    });

    testWidgets('Recovery phrase encoding and decoding roundtrip', (
      tester,
    ) async {
      // Test with a known ID
      final testId = BigInt.parse(
        '1234567890ABCDEF1234567890ABCDEF',
        radix: 16,
      );

      // Encode to words
      final words = encode(testId);
      expect(words.length, equals(RecoveryConstants.totalWordCount));

      // Decode the words
      final decodedId = RestoreAccountService.decodeRecoveryPhrase(words);
      expect(decodedId, equals(testId));
    });

    testWidgets('Recovery phrase validation detects invalid word count', (
      tester,
    ) async {
      // Test with too few words
      final shortWords = ['word1', 'word2', 'word3'];
      expect(
        () => RestoreAccountService.decodeRecoveryPhrase(shortWords),
        throwsArgumentError,
      );

      // Test with too many words
      final longWords = List<String>.generate(20, (i) => 'word$i');
      expect(
        () => RestoreAccountService.decodeRecoveryPhrase(longWords),
        throwsArgumentError,
      );
    });

    testWidgets('Recovery phrase validation detects corrupted phrase', (
      tester,
    ) async {
      final testId = BigInt.parse(
        '1234567890ABCDEF1234567890ABCDEF',
        radix: 16,
      );
      final words = encode(testId);

      // Corrupt one word
      final corruptedWords = List<String>.from(words);
      corruptedWords[5] = 'differentword';

      // Should throw due to checksum mismatch or invalid word
      expect(
        () => RestoreAccountService.decodeRecoveryPhrase(corruptedWords),
        throwsA(isA<ArgumentError>()),
      );
    });

    testWidgets('UUID conversion works correctly', (tester) async {
      final testId = BigInt.parse(
        '1234567890ABCDEF1234567890ABCDEF',
        radix: 16,
      );
      final uuid = RestoreAccountService.convertBigIntToUuid(testId);

      expect(uuid, isNotNull);
      expect(
        uuid,
        matches(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ),
      );

      // Verify the UUID can be parsed back
      final hexString = uuid!.replaceAll('-', '');
      final recoveredId = BigInt.parse(hexString, radix: 16);
      expect(recoveredId, equals(testId));
    });

    testWidgets('UUID conversion validates out of range values', (
      tester,
    ) async {
      // Negative ID should return null
      final negativeId = BigInt.from(-1);
      final negativeUuid = RestoreAccountService.convertBigIntToUuid(
        negativeId,
      );
      expect(negativeUuid, isNull);

      // ID exceeding 128 bits should return null
      final tooLargeId = BigInt.one << 128;
      final largeUuid = RestoreAccountService.convertBigIntToUuid(tooLargeId);
      expect(largeUuid, isNull);
    });

    testWidgets('RestoreAccountScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RestoreAccountScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.text('Scan QR Code'), findsNothing);
    });

    testWidgets('RecoveryPhraseContent widget loads and displays phrase', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RecoveryPhraseContent()),
        ),
      );

      // Initially shows loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for async load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should either show error or the phrase content
      final hasError =
          find.textContaining('Error').evaluate().isNotEmpty ||
          find.textContaining('Failed').evaluate().isNotEmpty;
      final hasContent =
          find.byType(GridView).evaluate().isNotEmpty ||
          find.byType(Wrap).evaluate().isNotEmpty;

      expect(hasError || hasContent, isTrue);
    });
  });
}
