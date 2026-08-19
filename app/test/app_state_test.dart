import 'dart:async';

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

SubjectProgress _progress(String subjectId) {
  return SubjectProgress(
    subjectId: subjectId,
    interventionId: _interventionId,
    taskId: _taskId,
    resultType: 'bool',
    result: Result<bool>.app(type: 'bool', periodId: _periodId, result: true),
  )..completedAt = DateTime.utc(2026, 8, 10, 8);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStoragePlatform originalPlatform;
  late Map<String, String> storageData;

  setUp(() {
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
        ..debugFetchRemoteSubjectForSync = (_) async => remoteSubject;

      await appState.retryCachedSubjectSynchronization();

      expect(appState.activeSubject?.progress, hasLength(1));
      expect(appState.activeSubject?.progress.single.taskId, _taskId);
      expect(appConnectionStatusController.status, AppConnectionStatus.healthy);
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
