import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/src/utils/user.dart';

void main() {
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
    'ensureParticipantSignedIn keeps credentials on connectivity failure',
    () async {
      appConnectionStatusController.reset();
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
