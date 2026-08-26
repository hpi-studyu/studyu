import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _studyId = 'study-id';
const _userId = 'user-id';
const _interventionId = 'intervention-a';
const _taskId = 'task-a';
const _periodId = 'period-a';

StudySubject _buildSubject() {
  final study = Study(_studyId, _userId)
    ..schedule.includeBaseline = false
    ..schedule.numberOfCycles = 1
    ..schedule.phaseDuration = 7
    ..interventions = [
      Intervention(_interventionId, 'Intervention A')
        ..tasks = [
          CheckmarkTask.withId()
            ..id = _taskId
            ..title = 'Task A',
        ],
    ];

  return StudySubject.fromStudy(
    study,
    _userId,
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  )..startedAt = DateTime.utc(2026, 8, 10);
}

SubjectProgress _progress(String subjectId, {DateTime? completedAt}) {
  return SubjectProgress(
    subjectId: subjectId,
    interventionId: _interventionId,
    taskId: _taskId,
    resultType: 'bool',
    result: Result<bool>.app(type: 'bool', periodId: _periodId, result: true),
  )..completedAt = completedAt ?? DateTime.utc(2026, 8, 10, 8);
}

class _SaveEmittingStudySubject extends StudySubject {
  _SaveEmittingStudySubject(StudySubject subject)
    : super(subject.id, subject.studyId, subject.userId, [
        ...subject.selectedInterventionIds,
      ]) {
    study = subject.study;
    progress = [...subject.progress];
    startedAt = subject.startedAt;
    inviteCode = subject.inviteCode;
    isDeleted = subject.isDeleted;
  }

  final _saveController = StreamController<StudySubject>();

  @override
  Stream<StudySubject> get onSave => _saveController.stream;

  void emitSave(StudySubject subject) => _saveController.add(subject);

  Future<void> close() => _saveController.close();

  @override
  bool operator ==(Object other) =>
      other is StudySubject &&
      jsonEncode(toFullJson()) == jsonEncode(other.toFullJson());

  @override
  int get hashCode => jsonEncode(toFullJson()).hashCode;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStoragePlatform originalPlatform;
  late Map<String, String> storageData;

  setUp(() {
    Cache.debugResetSubjectWrites();
    originalPlatform = FlutterSecureStoragePlatform.instance;
    storageData = {};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      storageData,
    );
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalPlatform;
    appConnectionStatusController.reset();
    Cache.debugUploadBlobFilesOverride = null;
    Cache.debugSaveProgressOverride = null;
    Cache.debugSaveSubjectOverride = null;
  });

  test('clearActiveStudyState removes stale active-study state', () {
    final appState = AppState();
    final study = Study(_studyId, _userId);
    final subject = StudySubject.fromStudy(study, _userId, const [], null);

    appState
      ..selectedStudy = study
      ..selectedInterventions = []
      ..activeSubject = subject
      ..inviteCode = 'invite-code'
      ..preselectedInterventionIds = ['intervention-a'];

    appState.clearActiveStudyState();

    expect(appState.selectedStudy, isNull);
    expect(appState.selectedInterventions, isNull);
    expect(appState.activeSubject, isNull);
    expect(appState.inviteCode, isNull);
    expect(appState.preselectedInterventionIds, isNull);
    expect(appState.studyNotifications, isNull);
  });

  test(
    'cache subscription ignores saves after active state teardown',
    () async {
      final appState = AppState();
      final subject = _SaveEmittingStudySubject(_buildSubject());

      appState.updateActiveSubject(subject);
      appState.clearActiveStudyState();
      subject.emitSave(_buildSubject());
      await Future<void>.delayed(Duration.zero);

      expect(appState.activeSubject, isNull);

      appState.dispose();
      await subject.close();
    },
  );

  test('cache subscription follows replacement subject saves', () async {
    final appState = AppState();
    final firstSubject = _SaveEmittingStudySubject(_buildSubject());
    final secondSubject = _SaveEmittingStudySubject(
      StudySubject.fromJson(firstSubject.toFullJson())
        ..progress = [_progress(firstSubject.id)],
    );
    final thirdSubject = _SaveEmittingStudySubject(
      StudySubject.fromJson(secondSubject.toFullJson())
        ..progress = [
          ...secondSubject.progress,
          _progress(
            secondSubject.id,
            completedAt: DateTime.utc(2026, 8, 10, 9),
          ),
        ],
    );

    appState.updateActiveSubject(firstSubject);
    firstSubject.emitSave(secondSubject);
    await Future<void>.delayed(Duration.zero);

    expect(appState.activeSubject, same(secondSubject));
    expect((await Cache.loadSubject()).progress, hasLength(1));

    secondSubject.emitSave(thirdSubject);
    await Future<void>.delayed(Duration.zero);

    expect(appState.activeSubject, same(thirdSubject));
    expect((await Cache.loadSubject()).progress, hasLength(2));

    appState.dispose();
    await firstSubject.close();
    await secondSubject.close();
    await thirdSubject.close();
  });

  test(
    'retryCachedSubjectSynchronization updates active subject from recovered remote subject',
    () async {
      final appState = AppState();
      final cachedSubject = _buildSubject();
      final remoteSubject = StudySubject.fromJson(cachedSubject.toFullJson())
        ..progress = [_progress(cachedSubject.id)];
      final staleSubject = StudySubject.fromJson(cachedSubject.toFullJson())
        ..progress = [];

      appState
        ..activeSubject = staleSubject
        ..selectedStudy = staleSubject.study
        ..setConnectionStatus(AppConnectionStatus.backendUnavailable)
        ..debugHasParticipantSessionForSync = () {
          return true;
        }
        ..debugFetchRemoteSubjectForSync = (_) async => remoteSubject;

      await appState.retryCachedSubjectSynchronization();

      expect(appState.activeSubject?.progress, hasLength(1));
      expect(appState.activeSubject?.progress.single.taskId, _taskId);
      expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
    },
  );

  test(
    'in-flight local completion is retained and reconciled on retry',
    () async {
      final appState = AppState();
      final currentSubject = _buildSubject();
      final remoteSubject = StudySubject.fromJson(currentSubject.toFullJson())
        ..progress = [
          _progress(
            currentSubject.id,
            completedAt: DateTime.utc(2026, 8, 10, 7),
          ),
        ];
      await Cache.storeSubject(currentSubject);
      Cache.debugUploadBlobFilesOverride = (_, _) async {};
      Cache.debugSaveProgressOverride = (progress) async => progress;
      Cache.debugSaveSubjectOverride = (subject) async => subject;
      final snapshotLoaded = Completer<void>();
      final releaseSynchronization = Completer<void>();
      Cache.debugAfterSubjectSnapshotLoaded = () async {
        snapshotLoaded.complete();
        await releaseSynchronization.future;
      };

      appState
        ..activeSubject = currentSubject
        ..selectedStudy = currentSubject.study
        ..debugActiveSubjectSyncRetryDelay = const Duration(hours: 1)
        ..debugHasParticipantSessionForSync = () {
          return true;
        }
        ..debugFetchRemoteSubjectForSync = (_) async => remoteSubject;

      final firstSynchronization = appState.retryCachedSubjectSynchronization();
      await snapshotLoaded.future;
      currentSubject.progress.add(
        _progress(currentSubject.id, completedAt: DateTime.utc(2026, 8, 10, 9)),
      );
      releaseSynchronization.complete();
      await firstSynchronization;

      expect(appState.activeSubject, same(currentSubject));
      expect(appState.activeSubject?.progress, hasLength(1));

      await Cache.storeSubject(currentSubject);
      Cache.debugAfterSubjectSnapshotLoaded = null;
      await appState.retryCachedSubjectSynchronization();

      expect(appState.activeSubject?.progress, hasLength(2));
      expect(
        appState.activeSubject?.progress.map(
          (progress) => progress.completedAt,
        ),
        containsAll([
          DateTime.utc(2026, 8, 10, 7),
          DateTime.utc(2026, 8, 10, 9),
        ]),
      );

      appState.dispose();
    },
  );

  test(
    'failed cached synchronization preserves active progress and degraded status',
    () async {
      final appState = AppState();
      final cachedSubject = _buildSubject();
      cachedSubject.progress = [_progress(cachedSubject.id)];
      final remoteSubject = StudySubject.fromJson(cachedSubject.toFullJson())
        ..progress = [];
      await Cache.storeSubject(cachedSubject);
      Cache.debugUploadBlobFilesOverride = (_, _) =>
          Future<void>.error(Exception('failed to fetch'));

      appState
        ..activeSubject = cachedSubject
        ..selectedStudy = cachedSubject.study
        ..debugHasParticipantSessionForSync = () {
          return true;
        }
        ..debugFetchRemoteSubjectForSync = (_) async {
          return remoteSubject;
        }
        ..setConnectionStatus(AppConnectionStatus.backendUnavailable);

      await appState.retryCachedSubjectSynchronization();

      expect(appState.activeSubject, same(cachedSubject));
      expect(appState.activeSubject?.progress, hasLength(1));
      expect(
        appConnectionStatusController.status,
        AppConnectionStatus.backendUnavailable,
      );

      appState.dispose();
    },
  );

  test(
    'retryCachedSubjectSynchronization restores session before retrying after auth failure',
    () async {
      final appState = AppState();
      final cachedSubject = _buildSubject();
      final remoteSubject = StudySubject.fromJson(cachedSubject.toFullJson())
        ..progress = [_progress(cachedSubject.id)];
      var fetchCalls = 0;
      var restoreCalls = 0;

      appState
        ..activeSubject = cachedSubject
        ..selectedStudy = cachedSubject.study
        ..setConnectionStatus(AppConnectionStatus.backendUnavailable)
        ..debugHasParticipantSessionForSync = () {
          return true;
        }
        ..debugFetchRemoteSubjectForSync = (_) async {
          fetchCalls++;
          if (fetchCalls == 1) {
            throw Exception('AuthApiException(code: invalid_jwt)');
          }
          return remoteSubject;
        }
        ..debugRestoreParticipantSessionForSync = () async {
          restoreCalls++;
          return true;
        };

      await appState.retryCachedSubjectSynchronization();

      expect(fetchCalls, 2);
      expect(restoreCalls, 1);
      expect(appState.activeSubject?.progress, hasLength(1));
      expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
    },
  );

  test(
    'sessionless recovery authenticates before the first protected fetch',
    () async {
      final appState = AppState();
      final cachedSubject = _buildSubject();
      final remoteSubject = StudySubject.fromJson(cachedSubject.toFullJson())
        ..progress = [_progress(cachedSubject.id)];
      final events = <String>[];
      var authenticated = false;
      var anonymousProtectedFetches = 0;

      appState
        ..activeSubject = cachedSubject
        ..selectedStudy = cachedSubject.study
        ..setConnectionStatus(AppConnectionStatus.backendUnavailable)
        ..debugHasParticipantSessionForSync = () {
          return false;
        }
        ..debugRestoreParticipantSessionForSync = () async {
          events.add('authenticate');
          authenticated = true;
          return true;
        }
        ..debugFetchRemoteSubjectForSync = (_) async {
          events.add('fetch');
          if (!authenticated) {
            anonymousProtectedFetches++;
            throw const PostgrestException(
              message: 'permission denied for table study_subject',
              code: '42501',
            );
          }
          return remoteSubject;
        };

      await appState.retryCachedSubjectSynchronization();

      expect(events, ['authenticate', 'fetch']);
      expect(anonymousProtectedFetches, 0);
      expect(appState.activeSubject?.progress, hasLength(1));
      expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
    },
  );

  test(
    'retryCachedSubjectSynchronization ignores rejected restore credentials',
    () async {
      final appState = AppState();
      final subject = _buildSubject();
      var fetchCalls = 0;
      var restoreCalls = 0;

      appState
        ..activeSubject = subject
        ..selectedStudy = subject.study
        ..setConnectionStatus(AppConnectionStatus.backendUnavailable)
        ..debugHasParticipantSessionForSync = () {
          return true;
        }
        ..debugFetchRemoteSubjectForSync = (_) {
          fetchCalls++;
          throw Exception('AuthApiException(code: invalid_jwt)');
        }
        ..debugRestoreParticipantSessionForSync = () {
          restoreCalls++;
          return Future<bool>.error(
            const AuthApiException(
              'Invalid login credentials',
              code: 'invalid_credentials',
            ),
          );
        };

      await expectLater(
        appState.retryCachedSubjectSynchronization(),
        completes,
      );

      expect(fetchCalls, 1);
      expect(restoreCalls, 1);
      expect(
        appConnectionStatusController.status,
        AppConnectionStatus.backendUnavailable,
      );
    },
  );

  test('marked synchronization retries while status remains healthy', () async {
    final appState = AppState();
    final cachedSubject = _buildSubject()..inviteCode = 'cached';
    cachedSubject.progress = [_progress(cachedSubject.id)];
    final remoteSubject = StudySubject.fromJson(cachedSubject.toFullJson())
      ..inviteCode = 'remote'
      ..progress = [];
    await Cache.storeSubject(cachedSubject);
    Cache.debugUploadBlobFilesOverride = (_, _) =>
        Future<void>.error(Exception('unclassified synchronization failure'));

    final startupSynchronization = await Cache.synchronize(remoteSubject);

    expect(startupSynchronization.succeeded, isFalse);
    expect(appConnectionStatusController.status, AppConnectionStatus.healthy);

    var fetchCalls = 0;
    var restoreCalls = 0;
    Cache.debugUploadBlobFilesOverride = (_, _) async {};
    Cache.debugSaveProgressOverride = (progress) async => progress;
    Cache.debugSaveSubjectOverride = (subject) async => subject;
    appState
      ..updateActiveSubject(startupSynchronization.subject)
      ..debugActiveSubjectSyncRetryDelay = const Duration(milliseconds: 1)
      ..debugHasParticipantSessionForSync = () {
        return true;
      }
      ..debugFetchRemoteSubjectForSync = (_) async {
        fetchCalls++;
        if (fetchCalls == 1) {
          throw Exception('AuthApiException(code: invalid_jwt)');
        }
        return remoteSubject;
      }
      ..debugRestoreParticipantSessionForSync = () async {
        restoreCalls++;
        return true;
      }
      ..markActiveSubjectSynchronizationPending();

    final deadline = DateTime.now().add(const Duration(seconds: 1));
    while (appState.activeSubject?.inviteCode != 'remote' &&
        DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }

    expect(fetchCalls, greaterThanOrEqualTo(2));
    expect(restoreCalls, 1);
    expect(appState.activeSubject?.inviteCode, 'remote');
    expect(appState.activeSubject?.progress, hasLength(1));
    expect(appConnectionStatusController.status, AppConnectionStatus.healthy);

    appState.dispose();
  });

  test(
    'scheduleActiveSubjectSyncRetryIfNeeded retries until healthy',
    () async {
      final appState = AppState();
      final subject = _buildSubject();
      var fetchCalls = 0;
      final completer = Completer<void>();

      appState
        ..activeSubject = subject
        ..selectedStudy = subject.study
        ..debugActiveSubjectSyncRetryDelay = const Duration(milliseconds: 1)
        ..debugHasParticipantSessionForSync = () {
          return true;
        }
        ..debugFetchRemoteSubjectForSync = (_) async {
          fetchCalls++;
          if (!completer.isCompleted) {
            completer.complete();
          }
          appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
          return subject;
        }
        ..setConnectionStatus(AppConnectionStatus.backendUnavailable);

      appState.scheduleActiveSubjectSyncRetryIfNeeded();
      await completer.future.timeout(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(fetchCalls, greaterThanOrEqualTo(1));
      expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
    },
  );
}
