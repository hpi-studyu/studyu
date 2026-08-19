import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    appConnectionStatusController.reset();
  });

  test(
    'restoreCachedValueForStartup returns cached value and skips sign-in on backend outage',
    () async {
      var signInCalls = 0;
      var fetchCalls = 0;

      final result = await restoreCachedValueForStartup<String>(
        fetchRemote: () {
          fetchCalls++;
          return Future<String?>.error(
            Exception('ClientException: Failed to fetch'),
          );
        },
        loadCached: () => Future.value('cached-subject'),
        signIn: () {
          signInCalls++;
          return Future.value(true);
        },
        isDeletedRemoteError: (_) => false,
      );

      expect(result, 'cached-subject');
      expect(fetchCalls, 1);
      expect(signInCalls, 0);
      expect(
        appConnectionStatusController.status,
        AppConnectionStatus.backendUnavailable,
      );
    },
  );

  test(
    'restoreCachedValueForStartup returns cached value and skips sign-in while device is offline',
    () async {
      var signInCalls = 0;
      var fetchCalls = 0;

      final result = await restoreCachedValueForStartup<String>(
        fetchRemote: () {
          fetchCalls++;
          return Future<String?>.error(
            Exception('SocketException: Network is unreachable'),
          );
        },
        loadCached: () => Future.value('cached-subject'),
        signIn: () {
          signInCalls++;
          return Future.value(true);
        },
        isDeletedRemoteError: (_) => false,
      );

      expect(result, 'cached-subject');
      expect(fetchCalls, 1);
      expect(signInCalls, 0);
      expect(
        appConnectionStatusController.status,
        AppConnectionStatus.deviceOffline,
      );
    },
  );

  test(
    'restoreCachedValueForStartup uses cache immediately once backend is already marked unavailable',
    () async {
      var signInCalls = 0;
      var fetchCalls = 0;

      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );

      final result = await restoreCachedValueForStartup<String>(
        fetchRemote: () {
          fetchCalls++;
          return Future.value('remote-subject');
        },
        loadCached: () => Future.value('cached-subject'),
        signIn: () {
          signInCalls++;
          return Future.value(true);
        },
        isDeletedRemoteError: (_) => false,
      );

      expect(result, 'cached-subject');
      expect(fetchCalls, 0);
      expect(signInCalls, 0);
      expect(
        appConnectionStatusController.status,
        AppConnectionStatus.backendUnavailable,
      );
    },
  );

  test(
    'restoreCachedValueForStartup throws cache unavailable when backend is down and cache is missing',
    () async {
      await expectLater(
        () => restoreCachedValueForStartup<String>(
          fetchRemote: () => Future<String?>.error(
            Exception('ClientException: Failed to fetch'),
          ),
          loadCached: () =>
              Future<String>.error(Exception('No cached subject found')),
          signIn: () => Future.value(true),
          isDeletedRemoteError: (_) => false,
        ),
        throwsA(isA<SubjectCacheUnavailableException>()),
      );
    },
  );

  test('rejected startup credentials reach deleted-subject recovery', () async {
    final originalStoragePlatform = FlutterSecureStoragePlatform.instance;
    final storageData = <String, String>{};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      storageData,
    );
    var authenticationCalls = 0;
    var loadCacheCalls = 0;

    try {
      await storeFakeUserEmailAndPassword(
        'participant@example.com',
        'password',
      );

      final rejectedCredentialsError = await tryRestoreParticipantSession(
        isLoggedIn: () => false,
        hasStoredCredentials: () async => true,
        signIn: () {
          authenticationCalls++;
          return Future<void>.error(
            const AuthApiException(
              'Invalid login credentials',
              code: 'invalid_credentials',
            ),
          );
        },
      );

      expect(await SecureStorage.read(userEmailKey), isNull);
      expect(await SecureStorage.read(userPasswordKey), isNull);

      await expectLater(
        () => restoreCachedValueForStartup<String>(
          fetchRemote: () => Future<String?>.error(Exception('expired JWT')),
          loadCached: () {
            loadCacheCalls++;
            return Future.value('cached-subject');
          },
          signIn: () => Future<bool>.error(rejectedCredentialsError!),
          isDeletedRemoteError: (_) => false,
        ),
        throwsA(isA<SubjectDeletedException>()),
      );

      expect(authenticationCalls, 1);
      expect(loadCacheCalls, 0);
    } finally {
      await clearParticipantCredentials();
      FlutterSecureStoragePlatform.instance = originalStoragePlatform;
    }
  });

  test(
    'restoreCachedValueForStartup maps deleted remote subject without using cache',
    () async {
      var loadCacheCalls = 0;
      var signInCalls = 0;

      await expectLater(
        () => restoreCachedValueForStartup<String>(
          fetchRemote: () => Future<String?>.error(Exception('PGRST116')),
          loadCached: () {
            loadCacheCalls++;
            return Future.value('cached-subject');
          },
          signIn: () {
            signInCalls++;
            return Future.value(true);
          },
          isDeletedRemoteError: (error) =>
              error.toString().contains('PGRST116'),
        ),
        throwsA(isA<SubjectDeletedException>()),
      );

      expect(loadCacheCalls, 0);
      expect(signInCalls, 0);
    },
  );
}
