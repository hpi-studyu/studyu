import 'dart:convert';

import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';
import 'package:studyu_flutter_common/src/utils/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _TestAsyncStorage extends GotrueAsyncStorage {
  const _TestAsyncStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> removeItem({required String key}) async {}

  @override
  Future<void> setItem({required String key, required String value}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStoragePlatform originalStoragePlatform;
  var signInRequests = 0;
  var signUpRequests = 0;

  setUpAll(() async {
    final authClient = MockClient((request) async {
      if (request.url.path.endsWith('/token')) {
        signInRequests++;
        return http.Response(
          jsonEncode({
            'code': 'invalid_credentials',
            'message': 'Invalid login credentials',
          }),
          400,
          headers: {'x-supabase-api-version': '2024-01-01'},
        );
      }
      if (request.url.path.endsWith('/signup')) {
        signUpRequests++;
        return http.Response(
          jsonEncode({
            'access_token': 'header.payload.signature',
            'expires_in': 3600,
            'refresh_token': 'refresh-token',
            'token_type': 'bearer',
            'user': {'id': '00000000-0000-0000-0000-000000000001'},
          }),
          200,
        );
      }
      return http.Response('', 404);
    });

    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-key',
      httpClient: authClient,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: false,
        detectSessionInUri: false,
        localStorage: EmptyLocalStorage(),
        pkceAsyncStorage: _TestAsyncStorage(),
      ),
    );
  });

  setUp(() {
    originalStoragePlatform = FlutterSecureStoragePlatform.instance;
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
    signInRequests = 0;
    signUpRequests = 0;
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalStoragePlatform;
    appConnectionStatusController.reset();
  });

  tearDownAll(() async {
    await Supabase.instance.dispose();
  });

  test('signInParticipant deletes rejected credentials and rethrows', () async {
    await storeFakeUserEmailAndPassword('old@example.com', 'old-password');

    await expectLater(
      signInParticipant(),
      throwsA(
        isA<AuthApiException>().having(
          (error) => error.code,
          'code',
          'invalid_credentials',
        ),
      ),
    );

    expect(signInRequests, 1);
    expect(await SecureStorage.read(userEmailKey), isNull);
    expect(await SecureStorage.read(userPasswordKey), isNull);
  });

  test('anonymousSignUp replaces rejected participant credentials', () async {
    await storeFakeUserEmailAndPassword('old@example.com', 'old-password');

    final success = await anonymousSignUp();

    expect(success, isTrue);
    expect(signInRequests, 1);
    expect(signUpRequests, 1);
    expect(
      await SecureStorage.read(userEmailKey),
      allOf(isNotNull, isNot('old@example.com')),
    );
    expect(
      await SecureStorage.read(userPasswordKey),
      allOf(isNotNull, isNot('old-password')),
    );
  });

  test('ensureParticipantSignedIn returns true for existing session', () async {
    var signInCalls = 0;
    var signUpCalls = 0;
    var validateCalls = 0;

    final success = await ensureParticipantSignedIn(
      isSignedIn: () => true,
      validateSession: () async {
        validateCalls++;
        return true;
      },
      signIn: () async {
        signInCalls++;
        return false;
      },
      signUp: () async {
        signUpCalls++;
        return false;
      },
    );

    expect(success, isTrue);
    expect(validateCalls, 1);
    expect(signInCalls, 0);
    expect(signUpCalls, 0);
  });

  test(
    'ensureParticipantSignedIn clears invalid current session before restoring credentials',
    () async {
      var clearSessionCalls = 0;
      var signInCalls = 0;
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => true,
        validateSession: () async => false,
        clearSession: () async {
          clearSessionCalls++;
        },
        signIn: () async {
          signInCalls++;
          return false;
        },
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isTrue);
      expect(clearSessionCalls, 1);
      expect(signInCalls, 1);
      expect(signUpCalls, 1);
    },
  );

  test(
    'ensureParticipantSignedIn reuses stored participant credentials',
    () async {
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => false,
        signIn: () async => true,
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isTrue);
      expect(signUpCalls, 0);
    },
  );

  test(
    'ensureParticipantSignedIn signs up when no session can be restored',
    () async {
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => false,
        signIn: () async => false,
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isTrue);
      expect(signUpCalls, 1);
    },
  );

  test(
    'ensureParticipantSignedIn replaces rejected participant credentials',
    () async {
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => false,
        signIn: () => Future<bool>.error(
          const AuthApiException(
            'Invalid login credentials',
            code: 'invalid_credentials',
          ),
        ),
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isTrue);
      expect(signUpCalls, 1);
    },
  );

  test(
    'ensureParticipantSignedIn keeps credentials on connectivity failure',
    () async {
      var signInCalls = 0;
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => true,
        validateSession: () => Future<bool>.error(
          Exception(
            'AuthRetryableFetchException(message: ClientException: Failed to fetch)',
          ),
        ),
        signIn: () async {
          signInCalls++;
          return true;
        },
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isFalse);
      expect(signInCalls, 0);
      expect(signUpCalls, 0);
      expect(
        appConnectionStatusController.status,
        AppConnectionStatus.backendUnavailable,
      );
    },
  );

  test(
    'ensureParticipantSignedIn trusts existing session while connectivity is degraded',
    () async {
      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );
      var validateCalls = 0;
      var signInCalls = 0;
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => true,
        validateSession: () async {
          validateCalls++;
          return false;
        },
        signIn: () async {
          signInCalls++;
          return false;
        },
        signUp: () async {
          signUpCalls++;
          return false;
        },
      );

      expect(success, isTrue);
      expect(validateCalls, 0);
      expect(signInCalls, 0);
      expect(signUpCalls, 0);
    },
  );

  test(
    'ensureParticipantSignedIn skips auth recovery without session while connectivity is degraded',
    () async {
      appConnectionStatusController.setStatus(
        AppConnectionStatus.deviceOffline,
      );
      var signInCalls = 0;
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => false,
        signIn: () async {
          signInCalls++;
          return true;
        },
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isFalse);
      expect(signInCalls, 0);
      expect(signUpCalls, 0);
    },
  );

  test('shouldAttemptParticipantAuthRecovery skips connectivity errors', () {
    expect(
      shouldAttemptParticipantAuthRecovery(
        Exception('ClientException: Failed to fetch'),
      ),
      isFalse,
    );
    expect(
      shouldAttemptParticipantAuthRecovery(
        Exception('AuthApiException(code: invalid_credentials)'),
      ),
      isTrue,
    );
  });

  test(
    'connectionStatusFromError keeps invalid credentials out of connectivity',
    () {
      expect(
        connectionStatusFromError(
          Exception('AuthApiException(code: invalid_credentials)'),
        ),
        isNull,
      );
    },
  );

  test(
    'connectionStatusFromError treats connection refused as backend unavailable',
    () {
      expect(
        connectionStatusFromError(
          Exception('SocketException: Connection refused'),
        ),
        AppConnectionStatus.backendUnavailable,
      );
    },
  );
}
