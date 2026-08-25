import 'dart:async';

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

const _studyId = 'study-id';
const _userId = 'user-id';
const _interventionAId = 'intervention-a';
const _interventionBId = 'intervention-b';
const _taskAId = 'task-a';
const _taskBId = 'task-b';
const _periodAId = 'period-a';
const _periodBId = 'period-b';

StudySubject _buildSubject() {
  final study = Study(_studyId, _userId)
    ..schedule.includeBaseline = false
    ..schedule.numberOfCycles = 1
    ..schedule.phaseDuration = 7
    ..interventions = [
      Intervention(_interventionAId, 'Intervention A')
        ..tasks = [
          CheckmarkTask.withId()
            ..id = _taskAId
            ..title = 'Task A',
        ],
      Intervention(_interventionBId, 'Intervention B')
        ..tasks = [
          CheckmarkTask.withId()
            ..id = _taskBId
            ..title = 'Task B',
        ],
    ];

  return StudySubject.fromStudy(
    study,
    _userId,
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  )..startedAt = DateTime.utc(2026, 8, 10);
}

SubjectProgress _progress({
  required String subjectId,
  required String interventionId,
  required String taskId,
  required String periodId,
  required DateTime completedAt,
}) {
  return SubjectProgress(
    subjectId: subjectId,
    interventionId: interventionId,
    taskId: taskId,
    resultType: 'bool',
    result: Result<bool>.app(type: 'bool', periodId: periodId, result: true),
  )..completedAt = completedAt;
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
    Cache.isSynchronizing = false;
    Cache.debugUploadBlobFilesOverride = null;
    Cache.debugSaveProgressOverride = null;
    Cache.debugSaveSubjectOverride = null;
  });

  group('Cache.buildProgressSyncPlan', () {
    test('merges local progress even when local and remote lengths match', () {
      final remoteSubject = _buildSubject();
      final localSubject = StudySubject.fromJson(remoteSubject.toFullJson());

      remoteSubject.progress = [
        _progress(
          subjectId: remoteSubject.id,
          interventionId: _interventionAId,
          taskId: _taskAId,
          periodId: _periodAId,
          completedAt: DateTime.utc(2026, 8, 10, 8),
        ),
      ];
      localSubject.progress = [
        _progress(
          subjectId: localSubject.id,
          interventionId: _interventionBId,
          taskId: _taskBId,
          periodId: _periodBId,
          completedAt: DateTime.utc(2026, 8, 11, 8),
        ),
      ];

      final plan = Cache.buildProgressSyncPlan(
        localSubject: localSubject,
        remoteSubject: remoteSubject,
      );

      expect(plan.hasChanges, isTrue);
      expect(plan.newProgress, hasLength(1));
      expect(plan.mergedProgress, hasLength(2));
      expect(
        plan.mergedProgress.map((progress) => progress.taskId),
        containsAll([_taskAId, _taskBId]),
      );
    });

    test('does not collapse separate tasks that share same timestamp', () {
      final remoteSubject = _buildSubject();
      final localSubject = StudySubject.fromJson(remoteSubject.toFullJson());
      final sharedTimestamp = DateTime.utc(2026, 8, 10, 8);

      remoteSubject.progress = [
        _progress(
          subjectId: remoteSubject.id,
          interventionId: _interventionAId,
          taskId: _taskAId,
          periodId: _periodAId,
          completedAt: sharedTimestamp,
        ),
      ];
      localSubject.progress = [
        _progress(
          subjectId: localSubject.id,
          interventionId: _interventionBId,
          taskId: _taskBId,
          periodId: _periodBId,
          completedAt: sharedTimestamp,
        ),
      ];

      final plan = Cache.buildProgressSyncPlan(
        localSubject: localSubject,
        remoteSubject: remoteSubject,
      );

      expect(plan.hasChanges, isTrue);
      expect(plan.mergedProgress, hasLength(2));
      expect(
        plan.mergedProgress.map((progress) => progress.taskId),
        containsAll([_taskAId, _taskBId]),
      );
    });

    test('does not resubmit already synchronized progress', () {
      final remoteSubject = _buildSubject();
      final localSubject = StudySubject.fromJson(remoteSubject.toFullJson());
      final sharedProgress = _progress(
        subjectId: remoteSubject.id,
        interventionId: _interventionAId,
        taskId: _taskAId,
        periodId: _periodAId,
        completedAt: DateTime.utc(2026, 8, 10, 8),
      );

      remoteSubject.progress = [sharedProgress];
      localSubject.progress = [
        SubjectProgress.fromJson(sharedProgress.toJson()),
      ];

      final plan = Cache.buildProgressSyncPlan(
        localSubject: localSubject,
        remoteSubject: remoteSubject,
      );

      expect(plan.hasChanges, isFalse);
      expect(plan.newProgress, isEmpty);
      expect(plan.mergedProgress, hasLength(1));
    });

    test('treats mismatched cached subject identity as incompatible', () {
      final remoteSubject = _buildSubject();
      final localSubject = StudySubject.fromJson(remoteSubject.toFullJson())
        ..id = 'different-subject-id';

      expect(
        Cache.isCompatibleCachedSubject(
          localSubject: localSubject,
          remoteSubject: remoteSubject,
        ),
        isFalse,
      );
    });
  });

  group('Cache partial retry behavior', () {
    test(
      'retry plan keeps only unsynced progress after partial save failure',
      () async {
        final remoteSubject = _buildSubject();
        final localSubject = StudySubject.fromJson(remoteSubject.toFullJson());
        final firstProgress = _progress(
          subjectId: localSubject.id,
          interventionId: _interventionAId,
          taskId: _taskAId,
          periodId: _periodAId,
          completedAt: DateTime.utc(2026, 8, 10, 8),
        );
        final secondProgress = _progress(
          subjectId: localSubject.id,
          interventionId: _interventionBId,
          taskId: _taskBId,
          periodId: _periodBId,
          completedAt: DateTime.utc(2026, 8, 11, 8),
        );
        localSubject.progress = [firstProgress, secondProgress];

        final firstPlan = Cache.buildProgressSyncPlan(
          localSubject: localSubject,
          remoteSubject: remoteSubject,
        );
        final savedProgress = <SubjectProgress>[];

        await expectLater(
          () => Cache.applyProgressSyncPlan(
            remoteSubject: remoteSubject,
            syncPlan: SubjectProgressSyncPlan(
              newProgress: firstPlan.newProgress,
              mergedProgress: firstPlan.mergedProgress,
              saveProgress: (progress) async {
                savedProgress.add(progress);
                if (savedProgress.length == 2) {
                  throw Exception('simulated second progress upload failure');
                }
                return progress;
              },
              saveSubject: (subject) async => subject,
            ),
          ),
          throwsException,
        );

        expect(savedProgress, hasLength(2));
        remoteSubject.progress = [firstProgress];

        final retryPlan = Cache.buildProgressSyncPlan(
          localSubject: localSubject,
          remoteSubject: remoteSubject,
        );

        expect(retryPlan.newProgress, hasLength(1));
        expect(retryPlan.newProgress.single.taskId, _taskBId);
      },
    );

    test('failed blob upload keeps remaining files queued for retry', () async {
      final uploads = <String>[];
      final deleted = <String>[];
      final blobA = FutureBlobFile('/tmp/upload-a', 'blob-a');
      final blobB = FutureBlobFile('/tmp/upload-b', 'blob-b');

      await expectLater(
        () => Cache.uploadPendingBlobFiles(
          futureBlobFiles: [blobA, blobB],
          uploadObservation: (futureBlobFile) async {
            uploads.add(futureBlobFile.futureBlobId);
            if (futureBlobFile.futureBlobId == blobB.futureBlobId) {
              throw Exception('simulated second blob upload failure');
            }
          },
          deleteUploadedFile: (futureBlobFile) async {
            deleted.add(futureBlobFile.futureBlobId);
          },
        ),
        throwsException,
      );

      expect(uploads, ['blob-a', 'blob-b']);
      expect(
        deleted,
        ['blob-a'],
        reason: 'Only successfully uploaded files should be removed from queue',
      );
    });

    test(
      'synchronize skips cached progress when cached subject belongs to different participant',
      () async {
        final remoteSubject = _buildSubject();
        final cachedSubject = StudySubject.fromJson(remoteSubject.toFullJson())
          ..id = 'different-subject-id'
          ..progress = [
            _progress(
              subjectId: 'different-subject-id',
              interventionId: _interventionBId,
              taskId: _taskBId,
              periodId: _periodBId,
              completedAt: DateTime.utc(2026, 8, 11, 8),
            ),
          ];
        final originalRemoteProgress = [
          _progress(
            subjectId: remoteSubject.id,
            interventionId: _interventionAId,
            taskId: _taskAId,
            periodId: _periodAId,
            completedAt: DateTime.utc(2026, 8, 10, 8),
          ),
        ];
        remoteSubject.progress = [...originalRemoteProgress];

        await Cache.storeSubject(cachedSubject);

        final synchronization = await Cache.synchronize(remoteSubject);

        expect(synchronization.succeeded, isTrue);
        expect(synchronization.subject.progress, hasLength(1));
        expect(synchronization.subject.progress.single.taskId, _taskAId);
        expect(
          synchronization.subject.progress.single.subjectId,
          remoteSubject.id,
        );
      },
    );

    test(
      'concurrent first cache write makes missing-cache synchronization retry',
      () async {
        final remoteSubject = _buildSubject();
        final latestSubject = StudySubject.fromJson(remoteSubject.toFullJson())
          ..progress = [
            _progress(
              subjectId: remoteSubject.id,
              interventionId: _interventionBId,
              taskId: _taskBId,
              periodId: _periodBId,
              completedAt: DateTime.utc(2026, 8, 11, 8),
            ),
          ];
        final snapshotLoaded = Completer<void>();
        final releaseSynchronization = Completer<void>();
        Cache.debugAfterSubjectSnapshotLoaded = () async {
          snapshotLoaded.complete();
          await releaseSynchronization.future;
        };

        final synchronizationFuture = Cache.synchronize(remoteSubject);
        await snapshotLoaded.future;
        await Cache.storeSubject(latestSubject);
        releaseSynchronization.complete();
        final synchronization = await synchronizationFuture;

        expect(synchronization.succeeded, isFalse);
        expect(synchronization.subject.progress, hasLength(1));
        expect(synchronization.subject.progress.single.taskId, _taskBId);
        expect((await Cache.loadSubject()).progress.single.taskId, _taskBId);
      },
    );

    test(
      'concurrent cache write makes equal-subject synchronization retry',
      () async {
        final remoteSubject = _buildSubject();
        await Cache.storeSubject(
          StudySubject.fromJson(remoteSubject.toFullJson()),
        );
        final latestSubject = StudySubject.fromJson(remoteSubject.toFullJson())
          ..progress = [
            _progress(
              subjectId: remoteSubject.id,
              interventionId: _interventionBId,
              taskId: _taskBId,
              periodId: _periodBId,
              completedAt: DateTime.utc(2026, 8, 11, 8),
            ),
          ];
        final snapshotLoaded = Completer<void>();
        final releaseSynchronization = Completer<void>();
        Cache.debugAfterSubjectSnapshotLoaded = () async {
          snapshotLoaded.complete();
          await releaseSynchronization.future;
        };

        final synchronizationFuture = Cache.synchronize(remoteSubject);
        await snapshotLoaded.future;
        await Cache.storeSubject(latestSubject);
        releaseSynchronization.complete();
        final synchronization = await synchronizationFuture;

        expect(synchronization.succeeded, isFalse);
        expect(synchronization.subject.progress, hasLength(1));
        expect(synchronization.subject.progress.single.taskId, _taskBId);
        expect((await Cache.loadSubject()).progress.single.taskId, _taskBId);
      },
    );

    test(
      'concurrent cache change is preserved and leaves synchronization pending',
      () async {
        final remoteSubject = _buildSubject();
        final cachedSubject = StudySubject.fromJson(remoteSubject.toFullJson())
          ..inviteCode = 'cached-before-sync';
        final latestSubject = StudySubject.fromJson(cachedSubject.toFullJson())
          ..progress = [
            _progress(
              subjectId: cachedSubject.id,
              interventionId: _interventionBId,
              taskId: _taskBId,
              periodId: _periodBId,
              completedAt: DateTime.utc(2026, 8, 11, 8),
            ),
          ];
        final synchronizationStarted = Completer<void>();
        final releaseSynchronization = Completer<void>();
        await Cache.storeSubject(cachedSubject);
        Cache.debugUploadBlobFilesOverride = (_, _) async {
          synchronizationStarted.complete();
          await releaseSynchronization.future;
        };

        final synchronizationFuture = Cache.synchronize(remoteSubject);
        await synchronizationStarted.future;
        await Cache.storeSubject(latestSubject);
        releaseSynchronization.complete();
        final synchronization = await synchronizationFuture;

        expect(synchronization.succeeded, isFalse);
        expect(synchronization.error, isNull);
        expect(synchronization.subject.progress, hasLength(1));
        expect(synchronization.subject.progress.single.taskId, _taskBId);
        final restored = await Cache.loadSubject();
        expect(restored.progress, hasLength(1));
        expect(restored.progress.single.taskId, _taskBId);
      },
    );

    test('successful progress merge is persisted to the cache', () async {
      final remoteSubject = _buildSubject();
      remoteSubject.progress = [
        _progress(
          subjectId: remoteSubject.id,
          interventionId: _interventionAId,
          taskId: _taskAId,
          periodId: _periodAId,
          completedAt: DateTime.utc(2026, 8, 10, 8),
        ),
      ];
      final cachedSubject = StudySubject.fromJson(remoteSubject.toFullJson())
        ..progress = [
          _progress(
            subjectId: remoteSubject.id,
            interventionId: _interventionBId,
            taskId: _taskBId,
            periodId: _periodBId,
            completedAt: DateTime.utc(2026, 8, 11, 8),
          ),
        ];
      await Cache.storeSubject(cachedSubject);
      Cache.debugUploadBlobFilesOverride = (_, _) async {};
      Cache.debugSaveProgressOverride = (progress) async => progress;
      Cache.debugSaveSubjectOverride = (subject) async => subject;

      final synchronization = await Cache.synchronize(remoteSubject);
      final restored = await Cache.loadSubject();

      expect(synchronization.succeeded, isTrue);
      expect(restored.progress, hasLength(2));
      expect(
        restored.progress.map((progress) => progress.taskId),
        containsAll([_taskAId, _taskBId]),
      );
    });

    test(
      'failed synchronization preserves cached progress and degraded status',
      () async {
        final remoteSubject = _buildSubject();
        final cachedSubject = StudySubject.fromJson(remoteSubject.toFullJson())
          ..progress = [
            _progress(
              subjectId: remoteSubject.id,
              interventionId: _interventionAId,
              taskId: _taskAId,
              periodId: _periodAId,
              completedAt: DateTime.utc(2026, 8, 10, 8),
            ),
          ];
        await Cache.storeSubject(cachedSubject);
        appConnectionStatusController.setStatus(
          AppConnectionStatus.backendUnavailable,
        );
        Cache.debugUploadBlobFilesOverride = (_, _) =>
            Future<void>.error(Exception('failed to fetch'));

        final synchronization = await Cache.synchronize(remoteSubject);

        expect(synchronization.succeeded, isFalse);
        expect(synchronization.subject.progress, hasLength(1));
        expect(synchronization.subject.progress.single.taskId, _taskAId);
        expect(
          appConnectionStatusController.status,
          AppConnectionStatus.backendUnavailable,
        );
        expect((await Cache.loadSubject()).progress, hasLength(1));
      },
    );
  });
}
