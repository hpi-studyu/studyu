import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

void main() {
  group('RestoreAccountService', () {
    tearDown(RestoreAccountService.clearCache);

    test('decodeRecoveryPhrase accepts German recovery phrases', () {
      final recoveryId = BigInt.parse(
        '1234567890ABCDEF1234567890ABCDEF',
        radix: 16,
      );
      final words = encode(recoveryId, wordlist: wordlistDe);

      expect(RestoreAccountService.decodeRecoveryPhrase(words), recoveryId);
    });

    test(
      'successful recovery clears old subject state before storing recovered subject',
      () async {
        final calls = <String>[];
        RestoreAccountService.debugConfigureRecoveryForTesting(
          recoverAccount: (_) async => RecoveryResult(
            success: true,
            email: 'recovered@example.com',
            password: 'password',
            subjectId: 'recovered-subject',
          ),
          storeCredentials: (_, _) async => calls.add('store credentials'),
          signInParticipant: () async {
            calls.add('sign in');
            return true;
          },
          clearActiveSubjectState: () async => calls.add('clear old subject'),
          storeActiveSubjectId: (subjectId) async =>
              calls.add('store $subjectId'),
        );
        RestoreAccountService.debugSubjectGetterForTesting = (_) async =>
            StudySubject.fromStudy(Study('study', 'owner'), 'owner', [], null);
        addTearDown(RestoreAccountService.debugResetRecoveryForTesting);
        addTearDown(RestoreAccountService.debugResetSubjectGetterForTesting);

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isTrue);
        expect(calls, [
          'store credentials',
          'sign in',
          'clear old subject',
          'store recovered-subject',
        ]);
      },
    );

    test('validateSubject propagates failed subject lookups', () async {
      RestoreAccountService.debugSubjectGetterForTesting = (_) async =>
          throw const PostgrestException(
            message: 'permission denied',
            code: '42501',
          );
      addTearDown(RestoreAccountService.debugResetSubjectGetterForTesting);

      await expectLater(
        RestoreAccountService.validateSubject('subject-id'),
        throwsA(
          isA<PostgrestException>().having(
            (error) => error.code,
            'code',
            '42501',
          ),
        ),
      );
    });

    test('validateSubject accepts a confirmed missing subject', () async {
      RestoreAccountService.debugSubjectGetterForTesting = (_) async =>
          throw const PostgrestException(
            message: 'JSON object requested, multiple (or no) rows returned',
            code: 'PGRST116',
          );
      addTearDown(RestoreAccountService.debugResetSubjectGetterForTesting);

      expect(
        await RestoreAccountService.validateSubject('subject-id'),
        isFalse,
      );
    });

    test('rotateRecoveryPhrase replaces the cached phrase', () async {
      const oldRecoveryId = '00000000-0000-0000-0000-000000000001';
      const newRecoveryId = '00000000-0000-0000-0000-000000000002';
      var fetchCount = 0;

      RestoreAccountService.debugCurrentUserIdGetterForTesting = () => 'user';
      RestoreAccountService.debugRecoveryIdGetterForTesting = () async {
        fetchCount++;
        return oldRecoveryId;
      };
      RestoreAccountService.debugRecoveryIdRotatorForTesting = () async =>
          newRecoveryId;
      addTearDown(
        RestoreAccountService.debugResetCurrentUserIdGetterForTesting,
      );
      addTearDown(RestoreAccountService.debugResetRecoveryIdGetterForTesting);
      addTearDown(RestoreAccountService.debugResetRecoveryIdRotatorForTesting);

      expect(
        await RestoreAccountService.getRecoveryPhrase(),
        encode(BigInt.one),
      );
      expect(
        await RestoreAccountService.rotateRecoveryPhrase(),
        encode(BigInt.two),
      );
      expect(
        await RestoreAccountService.getRecoveryPhrase(),
        encode(BigInt.two),
      );
      expect(fetchCount, 1);
    });

    test('rotation result is discarded when current user changes', () async {
      var currentUserId = 'first-user';
      RestoreAccountService.debugCurrentUserIdGetterForTesting = () =>
          currentUserId;
      RestoreAccountService.debugRecoveryIdRotatorForTesting = () async {
        currentUserId = 'second-user';
        return '00000000-0000-0000-0000-000000000002';
      };
      addTearDown(
        RestoreAccountService.debugResetCurrentUserIdGetterForTesting,
      );
      addTearDown(RestoreAccountService.debugResetRecoveryIdRotatorForTesting);

      expect(await RestoreAccountService.rotateRecoveryPhrase(), isNull);
    });

    test('failed rotation clears the cached phrase', () async {
      var fetchCount = 0;
      RestoreAccountService.debugCurrentUserIdGetterForTesting = () => 'user';
      RestoreAccountService.debugRecoveryIdGetterForTesting = () async {
        fetchCount++;
        return '00000000-0000-0000-0000-000000000001';
      };
      RestoreAccountService.debugRecoveryIdRotatorForTesting = () async => null;
      addTearDown(
        RestoreAccountService.debugResetCurrentUserIdGetterForTesting,
      );
      addTearDown(RestoreAccountService.debugResetRecoveryIdGetterForTesting);
      addTearDown(RestoreAccountService.debugResetRecoveryIdRotatorForTesting);

      await RestoreAccountService.getRecoveryPhrase();
      expect(await RestoreAccountService.rotateRecoveryPhrase(), isNull);
      await RestoreAccountService.getRecoveryPhrase();

      expect(fetchCount, 2);
    });

    test(
      'getRecoveryPhrase refreshes cache when current user changes',
      () async {
        const firstRecoveryId = '00000000-0000-0000-0000-000000000001';
        const secondRecoveryId = '00000000-0000-0000-0000-000000000002';
        var currentUserId = 'first-user';
        var currentRecoveryId = firstRecoveryId;

        RestoreAccountService.debugCurrentUserIdGetterForTesting = () =>
            currentUserId;
        RestoreAccountService.debugRecoveryIdGetterForTesting = () async =>
            currentRecoveryId;
        addTearDown(
          RestoreAccountService.debugResetCurrentUserIdGetterForTesting,
        );
        addTearDown(RestoreAccountService.debugResetRecoveryIdGetterForTesting);

        final firstPhrase = await RestoreAccountService.getRecoveryPhrase();
        currentUserId = 'second-user';
        currentRecoveryId = secondRecoveryId;
        final secondPhrase = await RestoreAccountService.getRecoveryPhrase();

        expect(firstPhrase, isNot(secondPhrase));
        expect(secondPhrase, encode(BigInt.two));
      },
    );
  });
}
