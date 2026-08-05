import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/src/utils/user.dart';

void main() {
  test('ensureParticipantSignedIn returns true for existing session', () async {
    var signInCalls = 0;
    var signUpCalls = 0;

    final success = await ensureParticipantSignedIn(
      isSignedIn: () => true,
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
    expect(signInCalls, 0);
    expect(signUpCalls, 0);
  });

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
