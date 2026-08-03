import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/participant_fitbit_credentials_service.dart';
import 'package:studyu_app/util/fitbit_handler.dart';

void main() {
  group('FitbitHandler', () {
    tearDown(ParticipantFitbitCredentialsService.debugResetTestingOverrides);

    test(
      'clearLocalFallbackCredentials delegates to participant service',
      () async {
        final deletedKeys = <String>[];
        ParticipantFitbitCredentialsService.debugReadAllLocalValuesForTesting =
            () async => {
              'fitbit_credentials_user-1_study-1': 'one',
              'fitbit_credentials_study-2': 'two',
            };
        ParticipantFitbitCredentialsService.debugDeleteLocalValueForTesting =
            (key) async {
              deletedKeys.add(key);
            };

        await FitbitHandler.clearLocalFallbackCredentials();

        expect(
          deletedKeys,
          containsAll([
            'fitbit_credentials_user-1_study-1',
            'fitbit_credentials_study-2',
          ]),
        );
      },
    );

    test(
      'clearLocalFallbackCredentialsForStudy forwards typed failure',
      () async {
        ParticipantFitbitCredentialsService.debugCurrentUserIdGetterForTesting =
            () => 'user-1';
        ParticipantFitbitCredentialsService.debugContainsLocalKeyForTesting =
            (key) async => true;
        ParticipantFitbitCredentialsService.debugDeleteLocalValueForTesting =
            (key) async => throw Exception('local delete failed');

        await expectLater(
          () => FitbitHandler.clearLocalFallbackCredentialsForStudy('study-1'),
          throwsA(isA<FitbitCredentialDeletionException>()),
        );
      },
    );
  });
}
