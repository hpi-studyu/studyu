import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.reset();
  });

  test(
    'tryRestoreParticipantSession skips network auth while connectivity is already degraded',
    () async {
      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );
      var signInCalls = 0;

      await tryRestoreParticipantSession(
        isLoggedIn: () => false,
        hasStoredCredentials: () async => true,
        signIn: () async {
          signInCalls++;
        },
      );

      expect(signInCalls, 0);
    },
  );
}
