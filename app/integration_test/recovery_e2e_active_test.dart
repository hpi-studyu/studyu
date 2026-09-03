import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'recovery_e2e_support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('recovers an active subject with persisted progress', (
    tester,
  ) async {
    await launchCleanApp(tester);
    await openRestoreAccount(tester);
    await submitPhrase(tester, activeRecoveryId);

    await waitFor(tester, find.text('Dashboard'));
    // This marker is rendered only when the recovered subject has persisted
    // subject_progress, rather than merely when the dashboard is present.
    expect(
      find.byKey(const ValueKey('dashboard_persisted_progress')),
      findsOneWidget,
    );
  });
}
