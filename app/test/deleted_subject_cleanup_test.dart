import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

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
  });

  test(
    'clearDeletedSubjectLocalState removes only stale subject state',
    () async {
      await SecureStorage.write(selectedSubjectIdKey, 'subject-1');
      await SecureStorage.write(cacheSubjectKey, 'cached-subject');
      await SecureStorage.write(userEmailKey, 'participant@example.com');
      await SecureStorage.write(userPasswordKey, 'password');

      await clearDeletedSubjectLocalState();

      expect(await SecureStorage.read(selectedSubjectIdKey), isNull);
      expect(await SecureStorage.read(cacheSubjectKey), isNull);
      expect(await SecureStorage.read(userEmailKey), 'participant@example.com');
      expect(await SecureStorage.read(userPasswordKey), 'password');
    },
  );
}
