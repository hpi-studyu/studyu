import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:studyu_app/util/study_local_cleanup.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

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
  final study = Study(studyId, 'owner-id');
  return StudySubject.fromStudy(study, userId, const [], null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStoragePlatform originalStoragePlatform;
  late PathProviderPlatform originalPathProviderPlatform;
  late Directory tempDirectory;
  late Directory documentsDirectory;

  setUp(() async {
    originalStoragePlatform = FlutterSecureStoragePlatform.instance;
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
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
}
