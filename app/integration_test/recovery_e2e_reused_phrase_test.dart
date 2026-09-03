import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'recovery_e2e_support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'rejects an already-used recovery phrase from a clean app state',
    (tester) async {
      // CI starts this target in a separate Flutter-drive process after the
      // successful active-account recovery target. Its browser/app lifecycle is
      // therefore independent and cannot restore that target's credentials,
      // selected subject, or in-memory app state.
      await launchCleanApp(tester);
      await openRestoreAccount(tester);
      await submitPhrase(tester, activeRecoveryId);
      await waitFor(
        tester,
        find.text(
          'Recovery failed. Please check your recovery phrase and try again.',
        ),
      );
    },
  );
}
