import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

const _studyId = 'study-id';
const _userId = 'user-id';
const _interventionId = 'intervention-a';
const _interventionBId = 'intervention-b';
const _checkmarkPeriodId = 'period-checkmark';
const _questionnairePeriodId = 'period-questionnaire';
const _questionId = 'question-upload';

StudySubject _buildSubject({
  required CheckmarkTask checkmarkTask,
  required QuestionnaireTask questionnaireTask,
}) {
  final study = Study(_studyId, _userId)
    ..title = 'Offline persistence study'
    ..status = StudyStatus.running
    ..schedule.includeBaseline = false
    ..schedule.numberOfCycles = 1
    ..schedule.phaseDuration = 7
    ..interventions = [
      Intervention(_interventionId, 'Intervention A'),
      Intervention(_interventionBId, 'Intervention B'),
    ]
    ..observations = [questionnaireTask];

  study.interventions.first.tasks = [checkmarkTask];

  return StudySubject.fromStudy(
    study,
    _userId,
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  )..startedAt = DateTime.now().subtract(const Duration(days: 1));
}

class _DelayedWriteSecureStoragePlatform
    extends TestFlutterSecureStoragePlatform {
  _DelayedWriteSecureStoragePlatform(super.data);

  final writeGate = Completer<void>();

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    await writeGate.future;
    await super.write(key: key, value: value, options: options);
  }
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> secureStorageData;
  late FlutterSecureStoragePlatform secureStoragePlatform;
  late PathProviderPlatform pathProviderPlatform;
  late Directory tempDirectory;
  late Directory documentsDirectory;

  setUp(() async {
    secureStorageData = {};
    secureStoragePlatform = FlutterSecureStoragePlatform.instance;
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      secureStorageData,
    );

    pathProviderPlatform = PathProviderPlatform.instance;
    final root = await Directory.systemTemp.createTemp(
      'studyu-offline-task-test-',
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
    FlutterSecureStoragePlatform.instance = secureStoragePlatform;
    PathProviderPlatform.instance = pathProviderPlatform;
    if (documentsDirectory.parent.existsSync()) {
      await documentsDirectory.parent.delete(recursive: true);
    }
  });

  test(
    'storeSubject waits for durable progress persistence before completing',
    () async {
      final completionPeriod = CompletionPeriod(
        id: _checkmarkPeriodId,
        unlockTime: StudyUTimeOfDay(hour: 8),
        lockTime: StudyUTimeOfDay(hour: 20),
      );
      final checkmarkTask = CheckmarkTask.withId()
        ..title = 'Rate your day'
        ..schedule.completionPeriods = [completionPeriod];
      final questionnaireTask = QuestionnaireTask.withId()
        ..title = 'Upload task';
      final subject = _buildSubject(
        checkmarkTask: checkmarkTask,
        questionnaireTask: questionnaireTask,
      );
      await subject.addResult<bool>(
        taskId: checkmarkTask.id,
        periodId: completionPeriod.id,
        result: true,
        offline: true,
      );
      final delayedStorage = _DelayedWriteSecureStoragePlatform(
        secureStorageData,
      );
      FlutterSecureStoragePlatform.instance = delayedStorage;
      var storeCompleted = false;

      final storeFuture = Cache.storeSubject(subject).whenComplete(() {
        storeCompleted = true;
      });
      await Future<void>.delayed(Duration.zero);

      expect(storeCompleted, isFalse);
      expect(secureStorageData, isNot(contains(cacheSubjectKey)));

      delayedStorage.writeGate.complete();
      await storeFuture;

      final restored = await Cache.loadSubject();
      expect(storeCompleted, isTrue);
      expect(restored.progress, hasLength(1));
      expect(
        restored.completedTaskInstanceForDay(
          checkmarkTask.id,
          completionPeriod,
          DateTime.now(),
        ),
        isTrue,
      );
    },
  );

  test(
    'offline checkmark completion persists subject progress across cache reload',
    () async {
      final checkmarkTask = CheckmarkTask.withId()
        ..title = 'Rate your day'
        ..schedule.completionPeriods = [
          CompletionPeriod(
            id: _checkmarkPeriodId,
            unlockTime: StudyUTimeOfDay(hour: 8),
            lockTime: StudyUTimeOfDay(hour: 20),
          ),
        ];
      final questionnaireTask = QuestionnaireTask.withId()
        ..title = 'Upload task'
        ..schedule.completionPeriods = [
          CompletionPeriod(
            id: _questionnairePeriodId,
            unlockTime: StudyUTimeOfDay(hour: 8),
            lockTime: StudyUTimeOfDay(hour: 20),
          ),
        ];

      final subject = _buildSubject(
        checkmarkTask: checkmarkTask,
        questionnaireTask: questionnaireTask,
      );

      await subject.addResult<bool>(
        taskId: checkmarkTask.id,
        periodId: _checkmarkPeriodId,
        result: true,
        offline: true,
      );
      await Cache.storeSubject(subject);

      final restored = await Cache.loadSubject();

      expect(restored.progress, hasLength(1));
      expect(restored.progress.single.completedAt, isNotNull);
      expect(
        restored.completedTaskForDay(checkmarkTask.id, DateTime.now()),
        isTrue,
      );
    },
  );

  test(
    'offline questionnaire media result survives cache reload and keeps pending upload file',
    () async {
      final checkmarkTask = CheckmarkTask.withId()
        ..title = 'Rate your day'
        ..schedule.completionPeriods = [
          CompletionPeriod(
            id: _checkmarkPeriodId,
            unlockTime: StudyUTimeOfDay(hour: 8),
            lockTime: StudyUTimeOfDay(hour: 20),
          ),
        ];
      final questionnaireTask = QuestionnaireTask.withId()
        ..title = 'Upload task'
        ..schedule.completionPeriods = [
          CompletionPeriod(
            id: _questionnairePeriodId,
            unlockTime: StudyUTimeOfDay(hour: 8),
            lockTime: StudyUTimeOfDay(hour: 20),
          ),
        ];

      final subject = _buildSubject(
        checkmarkTask: checkmarkTask,
        questionnaireTask: questionnaireTask,
      );

      final stagingFile = await TemporaryStorageHandler(
        _studyId,
        _userId,
      ).getStagingImage();
      expect(stagingFile, isNotNull);
      await File(stagingFile!.localFilePath).create(recursive: true);
      await File(stagingFile.localFilePath).writeAsString('image-bytes');

      final questionnaireState = QuestionnaireState();
      questionnaireState.answers[_questionId] = Answer<FutureBlobFile>(
        _questionId,
        DateTime.now(),
      )..response = stagingFile;

      await subject.addResult<QuestionnaireState>(
        taskId: questionnaireTask.id,
        periodId: _questionnairePeriodId,
        result: questionnaireState,
        offline: true,
      );
      await Cache.storeSubject(subject);

      final restored = await Cache.loadSubject();
      final restoredQuestionnaire =
          restored.progress.single.result.result as QuestionnaireState;
      final restoredAnswer =
          restoredQuestionnaire.answers[_questionId]! as Answer<String>;
      final pendingUploads = await TemporaryStorageHandler.getFutureBlobFiles();

      expect(restored.progress, hasLength(1));
      expect(restoredAnswer.response, stagingFile.futureBlobId);
      expect(
        pendingUploads.map((file) => file.futureBlobId),
        contains(stagingFile.futureBlobId),
      );
    },
  );

  test(
    'future blob file helpers filter and delete only matching subject scope',
    () async {
      final primaryHandler = TemporaryStorageHandler(_studyId, _userId);
      final otherHandler = TemporaryStorageHandler('study-b', 'user-b');

      final primaryImage = await primaryHandler.getStagingImage();
      final otherImage = await otherHandler.getStagingImage();
      expect(primaryImage, isNotNull);
      expect(otherImage, isNotNull);

      await File(primaryImage!.localFilePath).create(recursive: true);
      await File(primaryImage.localFilePath).writeAsString('primary');
      await TemporaryStorageHandler.moveStagingFileToUploadDirectory(
        primaryImage.localFilePath,
        primaryImage.futureBlobId,
      );

      await File(otherImage!.localFilePath).create(recursive: true);
      await File(otherImage.localFilePath).writeAsString('other');
      await TemporaryStorageHandler.moveStagingFileToUploadDirectory(
        otherImage.localFilePath,
        otherImage.futureBlobId,
      );

      final scopedFiles = await TemporaryStorageHandler.getFutureBlobFiles(
        studyId: _studyId,
        userId: _userId,
      );

      expect(scopedFiles.map((file) => file.futureBlobId), [
        primaryImage.futureBlobId,
      ]);

      await TemporaryStorageHandler.deleteFutureBlobFiles(
        studyId: _studyId,
        userId: _userId,
      );

      final remainingFiles = await TemporaryStorageHandler.getFutureBlobFiles();
      expect(remainingFiles.map((file) => file.futureBlobId), [
        otherImage.futureBlobId,
      ]);
    },
  );

  test(
    'cache synchronization uploads only pending files for remote subject',
    () async {
      final remoteSubject = _buildSubject(
        checkmarkTask: CheckmarkTask.withId(),
        questionnaireTask: QuestionnaireTask.withId(),
      );
      final localSubject = StudySubject.fromJson(remoteSubject.toFullJson())
        ..inviteCode = 'cached-invite';
      await Cache.storeSubject(localSubject);

      String? uploadedStudyId;
      String? uploadedUserId;
      Cache.debugUploadBlobFilesOverride = (studyId, userId) async {
        uploadedStudyId = studyId;
        uploadedUserId = userId;
      };

      final synchronized = await Cache.synchronize(remoteSubject);

      expect(synchronized, same(remoteSubject));
      expect(uploadedStudyId, remoteSubject.studyId);
      expect(uploadedUserId, remoteSubject.userId);

      Cache.debugUploadBlobFilesOverride = null;
    },
  );
}
