import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/participant_fitbit_credentials_service.dart';
import 'package:studyu_app/services/participant_study_exit_service.dart';
import 'package:studyu_core/core.dart';

void main() {
  group('ParticipantStudyExitService', () {
    tearDown(ParticipantStudyExitService.debugResetTestingOverrides);

    test(
      'remote Fitbit deletion failure does not leave flow half completed',
      () async {
        final events = <String>[];
        final subject = _FakeStudySubject(
          onSoftDelete: () async {
            events.add('soft_delete');
          },
        );
        ParticipantStudyExitService.debugRemoteFitbitDeletionForTesting =
            (_) async => throw const FitbitCredentialDeletionException(
              remoteDeletionFailed: true,
              localDeletionFailed: false,
            );

        final result = await ParticipantStudyExitService.exitStudy(
          subject: subject,
          mode: StudyExitMode.softDelete,
          notificationCleanup: () async {
            events.add('notifications');
          },
        );

        expect(result.success, isFalse);
        expect(events, isEmpty);
      },
    );

    test(
      'local Fitbit cleanup failure does not undo successful server deletion',
      () async {
        final events = <String>[];
        final subject = _FakeStudySubject(
          onDelete: () async {
            events.add('delete');
          },
        );
        ParticipantStudyExitService.debugRemoteFitbitDeletionForTesting =
            (_) async {
              events.add('remote_fitbit_delete');
            };
        ParticipantStudyExitService.debugLocalFitbitCleanupForTesting =
            (_) async => throw const FitbitCredentialDeletionException(
              remoteDeletionFailed: false,
              localDeletionFailed: true,
            );
        ParticipantStudyExitService.debugLocalDataDeletionForTesting =
            () async {
              events.add('delete_local_data');
            };
        ParticipantStudyExitService.debugRecoveryCacheClearerForTesting = () {
          events.add('clear_recovery_cache');
        };

        final result = await ParticipantStudyExitService.exitStudy(
          subject: subject,
          mode: StudyExitMode.hardDelete,
          notificationCleanup: () async {
            events.add('notifications');
          },
        );

        expect(result.success, isTrue);
        expect(result.localFitbitCleanupFailed, isTrue);
        expect(events, [
          'remote_fitbit_delete',
          'delete',
          'clear_recovery_cache',
          'delete_local_data',
          'notifications',
        ]);
      },
    );

    test('offline subject deletion failure is handled', () async {
      final subject = _FakeStudySubject(
        onSoftDelete: () {
          throw const SocketException('offline');
        },
      );
      ParticipantStudyExitService.debugRemoteFitbitDeletionForTesting =
          (_) async {};

      final result = await ParticipantStudyExitService.exitStudy(
        subject: subject,
        mode: StudyExitMode.softDelete,
        notificationCleanup: () async {},
      );

      expect(result.success, isFalse);
      expect(result.isOfflineFailure, isTrue);
    });

    test('successful deletion still completes cleanup order', () async {
      final events = <String>[];
      final subject = _FakeStudySubject(
        onSoftDelete: () async {
          events.add('soft_delete');
        },
      );
      ParticipantStudyExitService.debugRemoteFitbitDeletionForTesting =
          (_) async {
            events.add('remote_fitbit_delete');
          };
      ParticipantStudyExitService.debugLocalFitbitCleanupForTesting =
          (_) async {
            events.add('local_fitbit_cleanup');
          };
      ParticipantStudyExitService.debugActiveStudyReferenceDeletionForTesting =
          () async {
            events.add('clear_active_subject');
          };

      final result = await ParticipantStudyExitService.exitStudy(
        subject: subject,
        mode: StudyExitMode.softDelete,
        notificationCleanup: () async {
          events.add('notifications');
        },
      );

      expect(result.success, isTrue);
      expect(events, [
        'remote_fitbit_delete',
        'soft_delete',
        'clear_active_subject',
        'local_fitbit_cleanup',
        'notifications',
      ]);
    });
  });
}

class _FakeStudySubject extends StudySubject {
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onSoftDelete;

  _FakeStudySubject({this.onDelete, this.onSoftDelete})
    : super('subject-1', 'study-1', 'user-1', const []) {
    study = Study('study-1', 'owner-1');
  }

  @override
  Future<StudySubject> delete() async {
    await onDelete?.call();
    return this;
  }

  @override
  Future<StudySubject> softDelete() async {
    await onSoftDelete?.call();
    return this;
  }
}
