import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/recovery_local_transition_service.dart';

void main() {
  group('RecoveryLocalTransitionService', () {
    setUp(() {
      RecoveryLocalTransitionService.debugStoredEmailReaderForTesting =
          () async => null;
      RecoveryLocalTransitionService.debugStoredPasswordReaderForTesting =
          () async => null;
      RecoveryLocalTransitionService.debugActiveSubjectReaderForTesting =
          () async => null;
      RecoveryLocalTransitionService.debugStoredEmailDeleterForTesting =
          () async {};
      RecoveryLocalTransitionService.debugStoredPasswordDeleterForTesting =
          () async {};
      RecoveryLocalTransitionService.debugParticipantSignOutExecutorForTesting =
          () async {};
      RecoveryLocalTransitionService.debugActiveSubjectClearerForTesting =
          () async {};
      RecoveryLocalTransitionService.debugActiveSubjectWriterForTesting =
          (_) async {};
    });

    tearDown(RecoveryLocalTransitionService.debugResetTestingOverrides);

    test('captureSnapshot reads previous local identity state', () async {
      RecoveryLocalTransitionService.debugStoredEmailReaderForTesting =
          () async => 'old@test.local';
      RecoveryLocalTransitionService.debugStoredPasswordReaderForTesting =
          () async => 'old-password';
      RecoveryLocalTransitionService.debugActiveSubjectReaderForTesting =
          () async => 'subject-1';

      final snapshot = await RecoveryLocalTransitionService.captureSnapshot();

      expect(snapshot.previousEmail, 'old@test.local');
      expect(snapshot.previousPassword, 'old-password');
      expect(snapshot.previousActiveSubjectId, 'subject-1');
    });

    test('captureSnapshot fails when previous email read fails', () {
      RecoveryLocalTransitionService.debugStoredEmailReaderForTesting =
          () async => throw Exception('email read failed');

      expect(
        RecoveryLocalTransitionService.captureSnapshot,
        throwsA(isA<RecoveryLocalTransitionException>()),
      );
    });

    test('captureSnapshot fails when previous password read fails', () {
      RecoveryLocalTransitionService.debugStoredPasswordReaderForTesting =
          () async => throw Exception('password read failed');

      expect(
        RecoveryLocalTransitionService.captureSnapshot,
        throwsA(isA<RecoveryLocalTransitionException>()),
      );
    });

    test(
      'password write failure restores previous credentials and active subject',
      () async {
        final restored = <String>[];
        var signOutCalls = 0;

        RecoveryLocalTransitionService.debugStoredEmailWriterForTesting =
            (email) async {
              restored.add('email:$email');
            };
        RecoveryLocalTransitionService.debugStoredPasswordWriterForTesting =
            (password) async {
              if (password == 'recovered-password') {
                throw Exception('password write failed');
              }
              restored.add('password:$password');
            };
        RecoveryLocalTransitionService.debugActiveSubjectWriterForTesting =
            (subjectId) async {
              restored.add('subject:$subjectId');
            };
        RecoveryLocalTransitionService
            .debugParticipantSignOutExecutorForTesting = () async {
          signOutCalls++;
        };

        await expectLater(
          RecoveryLocalTransitionService.prepareForRecoveredAccount(
            snapshot: const RecoveryTransitionSnapshot(
              previousEmail: 'old@test.local',
              previousPassword: 'old-password',
              previousActiveSubjectId: 'subject-1',
            ),
            email: 'recovered@test.local',
            password: 'recovered-password',
          ),
          throwsA(isA<RecoveryLocalTransitionException>()),
        );

        expect(restored, [
          'email:recovered@test.local',
          'email:old@test.local',
          'password:old-password',
          'subject:subject-1',
        ]);
        expect(signOutCalls, 1);
      },
    );

    test(
      'active subject clear failure restores previous credentials and subject',
      () async {
        final restored = <String>[];
        var signOutCalls = 0;

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
        RecoveryLocalTransitionService.debugActiveSubjectWriterForTesting =
            (subjectId) async {
              restored.add('subject:$subjectId');
            };
        RecoveryLocalTransitionService
            .debugParticipantSignOutExecutorForTesting = () async {
          signOutCalls++;
        };

        await expectLater(
          RecoveryLocalTransitionService.prepareForRecoveredAccount(
            snapshot: const RecoveryTransitionSnapshot(
              previousEmail: 'old@test.local',
              previousPassword: 'old-password',
              previousActiveSubjectId: 'subject-1',
            ),
            email: 'recovered@test.local',
            password: 'recovered-password',
          ),
          throwsA(isA<RecoveryLocalTransitionException>()),
        );

        expect(restored, [
          'email:recovered@test.local',
          'password:recovered-password',
          'email:old@test.local',
          'password:old-password',
          'subject:subject-1',
        ]);
        expect(signOutCalls, 1);
      },
    );

    test(
      'failed password rollback deletes both credential keys to avoid mixed pair',
      () async {
        final deleted = <String>[];
        final restored = <String>[];

        RecoveryLocalTransitionService.debugStoredEmailWriterForTesting =
            (email) async {
              restored.add('email:$email');
            };
        RecoveryLocalTransitionService
            .debugStoredPasswordWriterForTesting = (password) async {
          if (password == 'recovered-password' || password == 'old-password') {
            throw Exception('password write failed');
          }
        };
        RecoveryLocalTransitionService.debugStoredEmailDeleterForTesting =
            () async {
              deleted.add('email');
            };
        RecoveryLocalTransitionService.debugStoredPasswordDeleterForTesting =
            () async {
              deleted.add('password');
            };

        await expectLater(
          RecoveryLocalTransitionService.prepareForRecoveredAccount(
            snapshot: const RecoveryTransitionSnapshot(
              previousEmail: 'old@test.local',
              previousPassword: 'old-password',
              previousActiveSubjectId: null,
            ),
            email: 'recovered@test.local',
            password: 'recovered-password',
          ),
          throwsA(isA<RecoveryLocalTransitionException>()),
        );

        expect(restored, [
          'email:recovered@test.local',
          'email:old@test.local',
        ]);
        expect(deleted, ['email', 'password']);
      },
    );
  });
}
