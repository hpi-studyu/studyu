import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';

void main() {
  late String originalEnvironment;

  setUp(() {
    originalEnvironment = SecureStorage.environment;
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(() {
    SecureStorage.environment = originalEnvironment;
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('scopes storage only for non-production debug environments', () {
    expect(effectiveStorageEnvironment('.env.dev', isDebug: true), '.env.dev');
    expect(
      effectiveStorageEnvironment('.env.local', isDebug: true),
      '.env.local',
    );
    expect(effectiveStorageEnvironment('.env', isDebug: true), '.env');
    expect(effectiveStorageEnvironment('.env.dev', isDebug: false), '.env');
  });

  test(
    'isolates direct secure storage values between debug environments',
    () async {
      SecureStorage.environment = '.env.dev';
      await SecureStorage.write('user_email', 'dev@example.com');

      SecureStorage.environment = '.env.local';
      expect(await SecureStorage.read('user_email'), isNull);
      await SecureStorage.write('user_email', 'local@example.com');

      SecureStorage.environment = '.env';
      expect(await SecureStorage.read('user_email'), isNull);
      await SecureStorage.write('user_email', 'prod@example.com');

      SecureStorage.environment = '.env.dev';
      expect(await SecureStorage.read('user_email'), 'dev@example.com');

      expect(
        await SecureStorage.storage.readAll(),
        containsPair('.env.dev:user_email', 'dev@example.com'),
      );
    },
  );

  test(
    'isolates persisted Supabase sessions between debug environments',
    () async {
      final storage = SupabaseStorage();

      SecureStorage.environment = '.env.dev';
      await storage.persistSession('dev-session');

      SecureStorage.environment = '.env.local';
      expect(await storage.accessToken(), isNull);
      await storage.persistSession('local-session');

      SecureStorage.environment = '.env.dev';
      expect(await storage.accessToken(), 'dev-session');
      await storage.removePersistedSession();
      expect(await storage.accessToken(), isNull);

      SecureStorage.environment = '.env.local';
      expect(await storage.accessToken(), 'local-session');
    },
  );
}
