import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/recovery_local_transition_service.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_core/core.dart';

const _recoveredEmail = 'recovered@test.local';
const _recoveredPassword = 'password-1';

void main() {
  group('RestoreAccountService', () {
    setUp(() {
      RecoveryLocalTransitionService.debugStoredEmailReaderForTesting =
          () async => null;
      RecoveryLocalTransitionService.debugStoredPasswordReaderForTesting =
          () async => null;
      RecoveryLocalTransitionService.debugStoredEmailDeleterForTesting =
          () async {};
      RecoveryLocalTransitionService.debugStoredPasswordDeleterForTesting =
          () async {};
      RecoveryLocalTransitionService.debugParticipantSignOutExecutorForTesting =
          () async {};
    });

    tearDown(() {
      RestoreAccountService.clearCache();
      RestoreAccountService.debugResetCurrentUserIdGetterForTesting();
      RestoreAccountService.debugResetRecoveryIdGetterForTesting();
      RestoreAccountService.debugResetRecoveryIdRotatorForTesting();
      RestoreAccountService.debugResetRecoverAccountExecutorForTesting();
      RestoreAccountService.debugResetParticipantSignInExecutorForTesting();
      RestoreAccountService.debugResetSubjectValidatorForTesting();
      RestoreAccountService.debugResetActiveSubjectStorerForTesting();
      RestoreAccountService.debugResetParticipantStateCleanupForTesting();
      RecoveryLocalTransitionService.debugResetTestingOverrides();
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
        final events = <String>[];

        RestoreAccountService.debugParticipantStateCleanupForTesting =
            () async {
              cleanupCalls++;
              events.add('cleanup');
            };
        RestoreAccountService.debugRecoverAccountExecutorForTesting =
            (_) async => _successfulRecoveryResult();
        RecoveryLocalTransitionService.debugStoredEmailWriterForTesting =
            (email) async {
              storedEmail = email;
              events.add('store_email');
            };
        RecoveryLocalTransitionService.debugStoredPasswordWriterForTesting =
            (password) async {
              storedPassword = password;
              events.add('store_password');
            };
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            (email, password) async {
              events.add('sign_in:$email:$password');
              return true;
            };
        RecoveryLocalTransitionService.debugActiveSubjectClearerForTesting =
            () async {
              events.add('clear_subject');
            };
        RestoreAccountService.debugSubjectValidatorForTesting = (_) async =>
            true;
        RestoreAccountService.debugActiveSubjectStorerForTesting =
            (subjectId) async {
              storedSubjectId = subjectId;
              events.add('store_subject');
            };

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isTrue);
        expect(cleanupCalls, 1);
        expect(storedEmail, 'recovered@test.local');
        expect(storedPassword, 'password-1');
        expect(storedSubjectId, 'subject-1');
        expect(events, [
          'sign_in:recovered@test.local:password-1',
          'store_email',
          'store_password',
          'clear_subject',
          'cleanup',
          'store_subject',
        ]);
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
            (_) async => _successfulRecoveryResult();
        RecoveryLocalTransitionService.debugCredentialStorerForTesting =
            (_, _) async {};
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            (_, _) async => true;
        RecoveryLocalTransitionService.debugActiveSubjectClearerForTesting =
            () async {
              clearedSubject++;
            };
        RestoreAccountService.debugSubjectValidatorForTesting = (_) async =>
            false;

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
            (_) async => _successfulRecoveryResult(subjectId: null);
        RecoveryLocalTransitionService.debugCredentialStorerForTesting =
            (_, _) async {};
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            (_, _) async => true;
        RecoveryLocalTransitionService.debugActiveSubjectClearerForTesting =
            () async {
              clearedSubject++;
            };

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isTrue);
        expect(clearedSubject, 1);
      },
    );

    test(
      'performRecovery does not clear participant state on failed sign in',
      () async {
        var cleanupCalls = 0;
        var credentialStoreCalls = 0;

        RestoreAccountService.debugParticipantStateCleanupForTesting =
            () async {
              cleanupCalls++;
            };
        RestoreAccountService.debugRecoverAccountExecutorForTesting =
            (_) async => _successfulRecoveryResult();
        RecoveryLocalTransitionService.debugStoredEmailWriterForTesting =
            (email) async {
              credentialStoreCalls++;
            };
        RecoveryLocalTransitionService.debugStoredPasswordWriterForTesting =
            (password) async {
              credentialStoreCalls++;
            };
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            (_, _) async => false;

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isFalse);
        expect(cleanupCalls, 0);
        expect(credentialStoreCalls, 0);
      },
    );

    test(
      'performRecovery returns cleanup failure after successful sign in',
      () async {
        var credentialStoreCalls = 0;
        var activeSubjectClearCalls = 0;

        RestoreAccountService.debugRecoverAccountExecutorForTesting =
            (_) async => _successfulRecoveryResult();
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            (_, _) async => true;
        RecoveryLocalTransitionService.debugStoredEmailWriterForTesting =
            (email) async {
              credentialStoreCalls++;
            };
        RecoveryLocalTransitionService.debugStoredPasswordWriterForTesting =
            (password) async {
              credentialStoreCalls++;
            };
        RecoveryLocalTransitionService.debugActiveSubjectClearerForTesting =
            () async {
              activeSubjectClearCalls++;
            };
        RestoreAccountService.debugParticipantStateCleanupForTesting =
            () async => throw Exception('cleanup failed');

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isFalse);
        expect(result.error, 'recovery_cleanup_failed');
        expect(credentialStoreCalls, 2);
        expect(activeSubjectClearCalls, 1);
      },
    );

    test('previous credentials are restored when email write throws', () async {
      final restored = <String>[];
      var signOutCalls = 0;
      var validateCalls = 0;

      RestoreAccountService.debugRecoverAccountExecutorForTesting = (_) async =>
          _successfulRecoveryResult();
      RestoreAccountService.debugParticipantSignInExecutorForTesting =
          (_, _) async => true;
      RecoveryLocalTransitionService.debugStoredEmailReaderForTesting =
          () async => 'old@test.local';
      RecoveryLocalTransitionService.debugStoredPasswordReaderForTesting =
          () async => 'old-password';
      RecoveryLocalTransitionService
          .debugStoredEmailWriterForTesting = (email) async {
        if (email == 'recovered@test.local') throw Exception('email failed');
        restored.add('email:$email');
      };
      RecoveryLocalTransitionService.debugStoredPasswordWriterForTesting =
          (password) async {
            restored.add('password:$password');
          };
      RecoveryLocalTransitionService.debugParticipantSignOutExecutorForTesting =
          () async {
            signOutCalls++;
          };
      RestoreAccountService.debugSubjectValidatorForTesting = (_) async {
        validateCalls++;
        return true;
      };

      final result = await RestoreAccountService.performRecovery(BigInt.one);

      expect(result.success, isFalse);
      expect(result.error, 'recovery_local_persistence_failed');
      expect(restored, ['email:old@test.local', 'password:old-password']);
      expect(signOutCalls, 1);
      expect(validateCalls, 0);
    });

    test(
      'previous credentials are restored when password write throws',
      () async {
        final restored = <String>[];
        var signOutCalls = 0;
        var validateCalls = 0;

        RestoreAccountService.debugRecoverAccountExecutorForTesting =
            (_) async => _successfulRecoveryResult();
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            (_, _) async => true;
        RecoveryLocalTransitionService.debugStoredEmailReaderForTesting =
            () async => 'old@test.local';
        RecoveryLocalTransitionService.debugStoredPasswordReaderForTesting =
            () async => 'old-password';
        RecoveryLocalTransitionService.debugStoredEmailWriterForTesting =
            (email) async {
              restored.add('email:$email');
            };
        RecoveryLocalTransitionService.debugStoredPasswordWriterForTesting =
            (password) async {
              if (password == 'password-1') {
                throw Exception('password failed');
              }
              restored.add('password:$password');
            };
        RecoveryLocalTransitionService
            .debugParticipantSignOutExecutorForTesting = () async {
          signOutCalls++;
        };
        RestoreAccountService.debugSubjectValidatorForTesting = (_) async {
          validateCalls++;
          return true;
        };

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isFalse);
        expect(result.error, 'recovery_local_persistence_failed');
        expect(restored, [
          'email:recovered@test.local',
          'email:old@test.local',
          'password:old-password',
        ]);
        expect(signOutCalls, 1);
        expect(validateCalls, 0);
      },
    );

    test(
      'previous credentials are restored when active subject clear throws',
      () async {
        final restored = <String>[];
        var signOutCalls = 0;
        var validateCalls = 0;

        RestoreAccountService.debugRecoverAccountExecutorForTesting =
            (_) async => _successfulRecoveryResult();
        RestoreAccountService.debugParticipantSignInExecutorForTesting =
            (_, _) async => true;
        RecoveryLocalTransitionService.debugStoredEmailReaderForTesting =
            () async => 'old@test.local';
        RecoveryLocalTransitionService.debugStoredPasswordReaderForTesting =
            () async => 'old-password';
        RecoveryLocalTransitionService.debugStoredEmailWriterForTesting =
            (email) async {
              restored.add('email:$email');
            };
        RecoveryLocalTransitionService.debugStoredPasswordWriterForTesting =
            (password) async {
              restored.add('password:$password');
            };
        RecoveryLocalTransitionService.debugActiveSubjectClearerForTesting =
            () async => throw Exception('clear failed');
        RecoveryLocalTransitionService
            .debugParticipantSignOutExecutorForTesting = () async {
          signOutCalls++;
        };
        RestoreAccountService.debugSubjectValidatorForTesting = (_) async {
          validateCalls++;
          return true;
        };

        final result = await RestoreAccountService.performRecovery(BigInt.one);

        expect(result.success, isFalse);
        expect(result.error, 'recovery_local_persistence_failed');
        expect(restored, [
          'email:recovered@test.local',
          'password:password-1',
          'email:old@test.local',
          'password:old-password',
        ]);
        expect(signOutCalls, 1);
        expect(validateCalls, 0);
      },
    );
  });
}

RecoveryResult _successfulRecoveryResult({String? subjectId = 'subject-1'}) {
  return RecoveryResult(
    success: true,
    email: _recoveredEmail,
    password: _recoveredPassword,
    subjectId: subjectId,
  );
}
