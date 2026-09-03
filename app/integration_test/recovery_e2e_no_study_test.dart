import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'recovery_e2e_support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('recovers a no-study account to public study selection', (
    tester,
  ) async {
    await launchCleanApp(tester);
    await openRestoreAccount(tester);
    await submitPhrase(tester, noStudyRecoveryId);

    await waitFor(tester, find.text('Browse public studies'));
    expect(find.text('Dashboard'), findsNothing);
    expect(find.textContaining('Something went wrong'), findsNothing);
  });
}
