import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_core/core.dart';

void main() {
  group('RestoreAccountService', () {
    tearDown(() {
      RestoreAccountService.clearCache();
      RestoreAccountService.debugResetCurrentUserIdGetterForTesting();
      RestoreAccountService.debugResetRecoveryIdGetterForTesting();
      RestoreAccountService.debugResetRecoveryIdRotatorForTesting();
      RestoreAccountService.debugResetRecoverAccountExecutorForTesting();
      RestoreAccountService.debugResetCredentialStorerForTesting();
      RestoreAccountService.debugResetParticipantSignInExecutorForTesting();
      RestoreAccountService.debugResetSubjectValidatorForTesting();
      RestoreAccountService.debugResetActiveSubjectStorerForTesting();
      RestoreAccountService.debugResetActiveSubjectClearerForTesting();
      RestoreAccountService.debugResetParticipantStateCleanupForTesting();
    });

    test('decodeRecoveryPhrase accepts German recovery phrases', () {
      final recoveryId = BigInt.parse(
        '1234567890ABCDEF1234567890ABCDEF',
        radix: 16,
      );
      final words = encode(recoveryId, wordlist: wordlistDe);

      expect(RestoreAccountService.decodeRecoveryPhrase(words), recoveryId);
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

    test(
      'performRecovery cleans previous participant state before switching',
      () async {
        var cleanupCalls = 0;
        String? storedEmail;
        String? storedPassword;
        String? storedSubjectId;

        RestoreAccountService.debugParticipantStateCleanupForTesting =
            () async {
              cleanupCalls++;
            };
        RestoreAccountService.debugRecoverAccountExecutorForTesting =
            (_) async => RecoveryResult(
              success: true,
              email: 'recovered@test.local',
              password: 'password-1',
              subjectId: 'subject-1',
            );
        RestoreAccountService.debugCredentialStorerForTesting =
            (email, password) async {
              storedEmail = email;
              storedPassword = password;
            };
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            () async => true;
        RestoreAccountService.debugSubjectValidatorForTesting = (_) async =>
            true;
        RestoreAccountService.debugActiveSubjectStorerForTesting =
            (subjectId) async {
              storedSubjectId = subjectId;
            };

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isTrue);
        expect(cleanupCalls, 1);
        expect(storedEmail, 'recovered@test.local');
        expect(storedPassword, 'password-1');
        expect(storedSubjectId, 'subject-1');
      },
    );

    test(
      'performRecovery does not clear participant state on failed recovery',
      () async {
        var cleanupCalls = 0;

        RestoreAccountService.debugParticipantStateCleanupForTesting =
            () async {
              cleanupCalls++;
            };
        RestoreAccountService.debugRecoverAccountExecutorForTesting =
            (_) async =>
                RecoveryResult(success: false, error: 'recovery_failed');

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isFalse);
        expect(cleanupCalls, 0);
      },
    );

    test(
      'performRecovery clears active subject when recovered subject is invalid',
      () async {
        var clearedSubject = 0;

        RestoreAccountService.debugParticipantStateCleanupForTesting =
            () async {};
        RestoreAccountService.debugRecoverAccountExecutorForTesting =
            (_) async => RecoveryResult(
              success: true,
              email: 'recovered@test.local',
              password: 'password-1',
              subjectId: 'subject-1',
            );
        RestoreAccountService.debugCredentialStorerForTesting = (_, _) async {};
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            () async => true;
        RestoreAccountService.debugSubjectValidatorForTesting = (_) async =>
            false;
        RestoreAccountService.debugActiveSubjectClearerForTesting = () async {
          clearedSubject++;
        };

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isTrue);
        expect(result.subjectId, isNull);
        expect(clearedSubject, 1);
      },
    );

    test(
      'performRecovery clears active subject when recovery has no subject',
      () async {
        var clearedSubject = 0;

        RestoreAccountService.debugParticipantStateCleanupForTesting =
            () async {};
        RestoreAccountService.debugRecoverAccountExecutorForTesting =
            (_) async => RecoveryResult(
              success: true,
              email: 'recovered@test.local',
              password: 'password-1',
            );
        RestoreAccountService.debugCredentialStorerForTesting = (_, _) async {};
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            () async => true;
        RestoreAccountService.debugActiveSubjectClearerForTesting = () async {
          clearedSubject++;
        };

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isTrue);
        expect(clearedSubject, 1);
      },
    );
  });
}
