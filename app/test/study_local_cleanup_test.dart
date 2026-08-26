import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/study_local_cleanup.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class _BlockedWriteSecureStoragePlatform
    extends TestFlutterSecureStoragePlatform {
  _BlockedWriteSecureStoragePlatform(super.data);

  final firstWriteStarted = Completer<void>();
  final releaseFirstWrite = Completer<void>();
  int writeCount = 0;

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    writeCount++;
    if (writeCount == 1) {
      firstWriteStarted.complete();
      await releaseFirstWrite.future;
    }
    await super.write(key: key, value: value, options: options);
  }
}

class _FailingDeleteSecureStoragePlatform
    extends TestFlutterSecureStoragePlatform {
  _FailingDeleteSecureStoragePlatform(super.data);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) {
    if (key == selectedSubjectIdKey) {
      return Future<void>.error(Exception('local cleanup failed'));
    }
    return super.delete(key: key, options: options);
  }
}

class _FailingWriteSecureStoragePlatform
    extends TestFlutterSecureStoragePlatform {
  _FailingWriteSecureStoragePlatform(super.data);

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) => Future<void>.error(Exception('cache recovery write failed'));
}

class _FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProviderPlatform({
    required this.temporaryPath,
    required this.applicationDocumentsPath,
  });

  final String temporaryPath;
  final String applicationDocumentsPath;

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      applicationDocumentsPath;
}

StudySubject _buildSubject({
  String studyId = 'study-id',
  String userId = 'user-id',
}) {
  final study = Study(studyId, 'owner-id')
    ..schedule.includeBaseline = false
    ..schedule.numberOfCycles = 1
    ..schedule.phaseDuration = 7
    ..interventions = [
      Intervention('intervention-id', 'Intervention'),
      Intervention('other-intervention-id', 'Other intervention'),
    ];
  return StudySubject.fromStudy(
    study,
    userId,
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  )..startedAt = DateTime.now().subtract(const Duration(days: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStoragePlatform originalStoragePlatform;
  late PathProviderPlatform originalPathProviderPlatform;
  late Map<String, String> storageData;
  late Directory tempDirectory;
  late Directory documentsDirectory;

  setUp(() async {
    Cache.debugResetSubjectWrites();
    originalStoragePlatform = FlutterSecureStoragePlatform.instance;
    storageData = {};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      storageData,
    );

    originalPathProviderPlatform = PathProviderPlatform.instance;
    final root = await Directory.systemTemp.createTemp(
      'studyu-study-local-cleanup-test-',
    );
    tempDirectory = Directory('${root.path}/temp')..createSync(recursive: true);
    documentsDirectory = Directory('${root.path}/documents')
      ..createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProviderPlatform(
      temporaryPath: tempDirectory.path,
      applicationDocumentsPath: documentsDirectory.path,
    );
  });

  tearDown(() async {
    FlutterSecureStoragePlatform.instance = originalStoragePlatform;
    PathProviderPlatform.instance = originalPathProviderPlatform;
    Cache.isSynchronizing = false;
    Cache.debugUploadBlobFilesOverride = null;
    Cache.debugSaveProgressOverride = null;
    Cache.debugSaveSubjectOverride = null;
    TemporaryStorageHandler.debugMoveStagingFileToUploadDirectory = null;
    debugSaveResultProgressOverride = null;
    debugSaveResultSubjectOverride = null;
    appConnectionStatusController.reset();
    if (documentsDirectory.parent.existsSync()) {
      await documentsDirectory.parent.delete(recursive: true);
    }
  });

  test(
    'clearStudyLocalData removes removed-study cache and scoped uploads but keeps participant credentials by default',
    () async {
      final subject = _buildSubject();
      final otherSubject = _buildSubject(
        studyId: 'other-study',
        userId: 'other-user',
      );
      await SecureStorage.write(selectedSubjectIdKey, subject.id);
      await SecureStorage.write(
        cacheSubjectKey,
        jsonEncode(subject.toFullJson()),
      );
      await storeFakeUserEmailAndPassword(
        'participant@$fakeStudyUEmailDomain',
        'password',
      );

      final subjectUpload = await TemporaryStorageHandler(
        subject.studyId,
        subject.userId,
      ).getStagingImage();
      final otherUpload = await TemporaryStorageHandler(
        otherSubject.studyId,
        otherSubject.userId,
      ).getStagingImage();
      expect(subjectUpload, isNotNull);
      expect(otherUpload, isNotNull);

      await File(subjectUpload!.localFilePath).create(recursive: true);
      await File(subjectUpload.localFilePath).writeAsString('subject');
      await TemporaryStorageHandler.moveStagingFileToUploadDirectory(
        subjectUpload.localFilePath,
        subjectUpload.futureBlobId,
      );

      await File(otherUpload!.localFilePath).create(recursive: true);
      await File(otherUpload.localFilePath).writeAsString('other');
      await TemporaryStorageHandler.moveStagingFileToUploadDirectory(
        otherUpload.localFilePath,
        otherUpload.futureBlobId,
      );

      await clearStudyLocalData(fallbackSubject: subject);

      expect(await SecureStorage.read(selectedSubjectIdKey), isNull);
      expect(await SecureStorage.read(cacheSubjectKey), isNull);
      expect(await getFakeUserEmail(), isNotNull);
      expect(await getFakeUserPassword(), isNotNull);
      expect(
        (await TemporaryStorageHandler.getFutureBlobFiles()).map(
          (file) => file.futureBlobId,
        ),
        [otherUpload.futureBlobId],
      );
    },
  );

  test(
    'clearStudyLocalData can also clear stored participant credentials for full reset flows',
    () async {
      final subject = _buildSubject();
      await SecureStorage.write(
        cacheSubjectKey,
        jsonEncode(subject.toFullJson()),
      );
      await storeFakeUserEmailAndPassword(
        'participant@$fakeStudyUEmailDomain',
        'password',
      );

      await clearStudyLocalData(
        fallbackSubject: subject,
        clearStoredParticipantCredentials: true,
      );

      expect(await getFakeUserEmail(), isNull);
      expect(await getFakeUserPassword(), isNull);
    },
  );

  test(
    'subject deletion cancels blocked synchronization before remote progress writes',
    () async {
      final remoteSubject = _buildSubject();
      final cachedSubject = StudySubject.fromJson(remoteSubject.toFullJson())
        ..progress = [
          SubjectProgress(
            subjectId: remoteSubject.id,
            interventionId: 'intervention-id',
            taskId: 'task-id',
            resultType: 'bool',
            result: Result<bool>.app(
              type: 'bool',
              periodId: 'period-id',
              result: true,
            ),
          )..completedAt = DateTime.utc(2026, 8, 21, 8),
        ];
      await Cache.storeSubject(cachedSubject);
      final synchronizationStarted = Completer<void>();
      final releaseSynchronization = Completer<void>();
      final releaseRemoteDeletion = Completer<void>();
      var uploadAttempts = 0;
      var savedProgressCount = 0;
      var savedSubjectCount = 0;
      var remoteDeletionStarted = false;
      Cache.debugUploadBlobFilesOverride = (_, _) async {
        uploadAttempts++;
        synchronizationStarted.complete();
        await releaseSynchronization.future;
      };
      Cache.debugSaveProgressOverride = (progress) async {
        savedProgressCount++;
        return progress;
      };
      Cache.debugSaveSubjectOverride = (subject) async {
        savedSubjectCount++;
        return subject;
      };

      final synchronizationFuture = Cache.synchronize(remoteSubject);
      await synchronizationStarted.future;
      final deletionFuture = deleteStudySubjectAndClearLocalData(
        subject: cachedSubject,
        deleteRemoteSubject: () async {
          remoteDeletionStarted = true;
          await releaseRemoteDeletion.future;
        },
        onRemoteDeleted: () {},
        stopActiveSynchronization: () async {},
        resumeActiveSynchronization: () {},
      );
      await Future<void>.delayed(Duration.zero);

      expect(remoteDeletionStarted, isFalse);

      releaseSynchronization.complete();
      final synchronization = await synchronizationFuture;
      while (!remoteDeletionStarted) {
        await Future<void>.delayed(Duration.zero);
      }
      final blockedSynchronization = await Cache.synchronize(remoteSubject);

      expect(synchronization.succeeded, isFalse);
      expect(blockedSynchronization.succeeded, isFalse);
      expect(uploadAttempts, 1);
      expect(savedProgressCount, 0);
      expect(savedSubjectCount, 0);

      releaseRemoteDeletion.complete();
      await deletionFuture;

      expect(await SecureStorage.containsKey(cacheSubjectKey), isFalse);
    },
  );

  test(
    'subject deletion waits for addResult before staging file movement',
    () async {
      final subject = _buildSubject();
      final questionnaireState = QuestionnaireState();
      questionnaireState.answers['question-id'] = Answer<FutureBlobFile>(
        'question-id',
        DateTime.now(),
      )..response = FutureBlobFile('/tmp/staging.jpg', 'future-blob.jpg');
      final moveStarted = Completer<void>();
      final releaseMove = Completer<void>();
      var remoteDeletionStarted = false;
      var uploadCount = 0;
      var progressSaveCount = 0;
      var subjectSaveCount = 0;
      var mutationAfterDeletion = false;
      TemporaryStorageHandler.debugMoveStagingFileToUploadDirectory =
          (stagingFilePath, blobId) async {
            expect(stagingFilePath, '/tmp/staging.jpg');
            expect(blobId, 'future-blob.jpg');
            moveStarted.complete();
            await releaseMove.future;
          };
      Cache.debugUploadBlobFilesOverride = (_, _) async {
        mutationAfterDeletion |= remoteDeletionStarted;
        uploadCount++;
      };
      debugSaveResultProgressOverride = (progress) async {
        mutationAfterDeletion |= remoteDeletionStarted;
        progressSaveCount++;
        return progress;
      };
      debugSaveResultSubjectOverride = (savedSubject) async {
        mutationAfterDeletion |= remoteDeletionStarted;
        subjectSaveCount++;
        return savedSubject;
      };

      final resultMutation = subject.addResult<QuestionnaireState>(
        taskId: 'task-id',
        periodId: 'period-id',
        result: questionnaireState,
      );
      await moveStarted.future;

      final deletion = deleteStudySubjectAndClearLocalData(
        subject: subject,
        deleteRemoteSubject: () async {
          remoteDeletionStarted = true;
          subject.isDeleted = true;
        },
        onRemoteDeleted: () {},
        stopActiveSynchronization: () async {},
        resumeActiveSynchronization: () {},
      );
      await Future<void>.delayed(Duration.zero);

      expect(remoteDeletionStarted, isFalse);

      releaseMove.complete();
      await resultMutation;
      await deletion;

      expect(remoteDeletionStarted, isTrue);
      expect(mutationAfterDeletion, isFalse);
      expect(uploadCount, 1);
      expect(progressSaveCount, 1);
      expect(subjectSaveCount, 1);
      expect(subject.isDeleted, isTrue);
    },
  );

  test(
    'subject deletion waits for active authentication restoration',
    () async {
      final subject = _buildSubject();
      final appState = AppState()..updateActiveSubject(subject);
      final restorationStarted = Completer<void>();
      final releaseRestoration = Completer<void>();
      var remoteDeletionStarted = false;
      appState
        ..debugHasParticipantSessionForSync = () {
          return false;
        }
        ..debugRestoreParticipantSessionForSync = () async {
          restorationStarted.complete();
          await releaseRestoration.future;
          return false;
        };

      final retry = appState.retryCachedSubjectSynchronization();
      await restorationStarted.future;
      final deletion = deleteStudySubjectAndClearLocalData(
        subject: subject,
        deleteRemoteSubject: () async {
          remoteDeletionStarted = true;
        },
        onRemoteDeleted: appState.clearActiveStudyState,
        stopActiveSynchronization:
            appState.stopAndAwaitActiveSubjectSynchronization,
        resumeActiveSynchronization:
            appState.resumeActiveSubjectSynchronization,
      );
      await Future<void>.delayed(Duration.zero);

      expect(remoteDeletionStarted, isFalse);

      releaseRestoration.complete();
      await Future.wait([retry, deletion]);

      expect(remoteDeletionStarted, isTrue);
      expect(appState.activeSubject, isNull);
      appState.dispose();
    },
  );

  test(
    'failed deletion preserves its error and automatically resumes synchronization when cache recovery fails',
    () async {
      final subject = _buildSubject();
      final remoteDeletionError = Exception('remote deletion failed');
      final appState = AppState()
        ..debugActiveSubjectSyncRetryDelay = const Duration(milliseconds: 1)
        ..updateActiveSubject(subject);
      var fetchCalls = 0;
      appState
        ..debugHasParticipantSessionForSync = () {
          return true;
        }
        ..debugFetchRemoteSubjectForSync = (_) async {
          fetchCalls++;
          return subject;
        };
      FlutterSecureStoragePlatform.instance =
          _FailingWriteSecureStoragePlatform(storageData);

      await expectLater(
        deleteStudySubjectAndClearLocalData(
          subject: subject,
          deleteRemoteSubject: () => Future<void>.error(remoteDeletionError),
          onRemoteDeleted: appState.clearActiveStudyState,
          stopActiveSynchronization:
              appState.stopAndAwaitActiveSubjectSynchronization,
          resumeActiveSynchronization:
              appState.resumeActiveSubjectSynchronization,
        ),
        throwsA(same(remoteDeletionError)),
      );

      final deadline = DateTime.now().add(const Duration(seconds: 1));
      while (fetchCalls == 0 && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }

      expect(appState.activeSubject, same(subject));
      expect(fetchCalls, greaterThanOrEqualTo(1));
      appState.dispose();
    },
  );

  test(
    'full reset clears restored session and stops later refresh persistence',
    () async {
      final subject = _buildSubject();
      final appState = AppState()..updateActiveSubject(subject);
      final restorationStarted = Completer<void>();
      final releaseRestoration = Completer<void>();
      final sessionStorage = SupabaseStorage();
      var sessionActive = true;
      var autoRefreshActive = true;
      var resetCompleted = false;
      appState
        ..debugHasParticipantSessionForSync = () {
          return false;
        }
        ..debugRestoreParticipantSessionForSync = () async {
          restorationStarted.complete();
          await releaseRestoration.future;
          await sessionStorage.persistSession('restored-session');
          return false;
        };

      final retry = appState.retryCachedSubjectSynchronization();
      await restorationStarted.future;
      final reset = () async {
        await appState.stopAndAwaitActiveSubjectSynchronization();
        appState.clearActiveStudyState();
        await clearAllLocalData(
          stopAutoRefresh: () {
            autoRefreshActive = false;
          },
          clearSession: () async {
            sessionActive = false;
          },
        );
        resetCompleted = true;
      }();
      await Future<void>.delayed(Duration.zero);

      expect(resetCompleted, isFalse);

      releaseRestoration.complete();
      await Future.wait([retry, reset]);
      if (sessionActive && autoRefreshActive) {
        await sessionStorage.persistSession('refreshed-session');
      }

      expect(resetCompleted, isTrue);
      expect(sessionActive, isFalse);
      expect(autoRefreshActive, isFalse);
      expect(storageData, isEmpty);
      appState.dispose();
    },
  );

  test('full reset continues when session shutdown is unavailable', () async {
    await SupabaseStorage().persistSession('live-session');
    var stopRefreshCalls = 0;
    var clearSessionCalls = 0;

    await clearAllLocalData(
      stopAutoRefresh: () {
        stopRefreshCalls++;
        throw StateError('Supabase is not initialized');
      },
      clearSession: () {
        clearSessionCalls++;
        return Future<void>.error(Exception('backend unavailable'));
      },
    );

    expect(stopRefreshCalls, 1);
    expect(clearSessionCalls, 1);
    expect(storageData, isEmpty);
  });

  test(
    'remote deletion tears down active state before local cleanup failure',
    () async {
      final subject = _buildSubject();
      final appState = AppState()
        ..updateActiveSubject(subject)
        ..debugActiveSubjectSyncRetryDelay = const Duration(milliseconds: 1);
      var fetchCalls = 0;
      var remoteDeleted = false;
      appState
        ..debugHasParticipantSessionForSync = () {
          return true;
        }
        ..debugFetchRemoteSubjectForSync = (_) async {
          fetchCalls++;
          return subject;
        };
      FlutterSecureStoragePlatform.instance =
          _FailingDeleteSecureStoragePlatform(storageData);
      await SecureStorage.write(selectedSubjectIdKey, subject.id);

      await expectLater(
        deleteStudySubjectAndClearLocalData(
          subject: subject,
          deleteRemoteSubject: () async {
            remoteDeleted = true;
          },
          onRemoteDeleted: appState.clearActiveStudyState,
          stopActiveSynchronization:
              appState.stopAndAwaitActiveSubjectSynchronization,
          resumeActiveSynchronization:
              appState.resumeActiveSubjectSynchronization,
        ),
        throwsException,
      );

      expect(remoteDeleted, isTrue);
      expect(appState.activeSubject, isNull);

      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );
      appState.scheduleActiveSubjectSyncRetryIfNeeded();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(fetchCalls, 0);
      appState.dispose();
    },
  );

  test(
    'full reset drains queued writes and rejects late cache writes',
    () async {
      final firstSubject = _buildSubject();
      final queuedSubject = _buildSubject(studyId: 'queued-study');
      final lateSubject = _buildSubject(studyId: 'late-study');
      final blockedStorage = _BlockedWriteSecureStoragePlatform(storageData);
      FlutterSecureStoragePlatform.instance = blockedStorage;

      final firstWrite = Cache.storeSubject(firstSubject);
      await blockedStorage.firstWriteStarted.future;
      final queuedWrite = Cache.storeSubject(queuedSubject);
      final reset = clearAllLocalData();
      final lateWrite = Cache.storeSubject(lateSubject);

      blockedStorage.releaseFirstWrite.complete();
      await Future.wait([firstWrite, queuedWrite, lateWrite, reset]);

      expect(await SecureStorage.containsKey(cacheSubjectKey), isFalse);
      expect(storageData, isEmpty);
    },
  );
}
