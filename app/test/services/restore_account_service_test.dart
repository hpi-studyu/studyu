import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_core/core.dart';

void main() {
  group('RestoreAccountService', () {
    tearDown(RestoreAccountService.clearCache);

    test('RecoveryResult reads the replacement recovery ID', () {
      final result = RecoveryResult.fromJson({
        'success': true,
        'recovery_id': '00000000-0000-4000-8000-000000000002',
      });

      expect(result.recoveryId, '00000000-0000-4000-8000-000000000002');
    });

    test('decodeRecoveryPhrase accepts German recovery phrases', () {
      final recoveryId = BigInt.parse(
        '1234567890ABCDEF1234567890ABCDEF',
        radix: 16,
      );
      final words = encode(recoveryId, wordlist: wordlistDe);

      expect(RestoreAccountService.decodeRecoveryPhrase(words), recoveryId);
    });

    test(
      'getRecoveryPhrase refreshes cache when current user changes',
      () async {
        const firstRecoveryId = '00000000-0000-0000-0000-000000000001';
        const secondRecoveryId = '00000000-0000-0000-0000-000000000002';
        var currentUserId = 'first-user';
        var currentRecoveryId = firstRecoveryId;

        RestoreAccountService.debugCurrentUserIdGetterForTesting = () =>
            currentUserId;
        RestoreAccountService.debugRecoveryIdGetterForTesting = () async =>
            currentRecoveryId;
        addTearDown(
          RestoreAccountService.debugResetCurrentUserIdGetterForTesting,
        );
        addTearDown(RestoreAccountService.debugResetRecoveryIdGetterForTesting);

        final firstPhrase = await RestoreAccountService.getRecoveryPhrase();
        currentUserId = 'second-user';
        currentRecoveryId = secondRecoveryId;
        final secondPhrase = await RestoreAccountService.getRecoveryPhrase();

        expect(firstPhrase, isNot(secondPhrase));
        expect(secondPhrase, encode(BigInt.two));
      },
    );
  });
}
