import 'dart:convert';

import 'package:fitbitter/fitbitter.dart' as fitbitter;
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/services/participant_fitbit_credentials_service.dart';

void main() {
  group('ParticipantFitbitCredentialsService', () {
    late Map<String, String> storage;
    late fitbitter.FitbitCredentials serverCredentials;
    late fitbitter.FitbitCredentials scopedCredentials;

    setUp(() {
      storage = {};
      serverCredentials = _credentials('server-user');
      scopedCredentials = _credentials('local-user');

      ParticipantFitbitCredentialsService.debugCurrentUserIdGetterForTesting =
          () => 'user-1';
      ParticipantFitbitCredentialsService.debugReadLocalValueForTesting =
          (key) async => storage[key];
      ParticipantFitbitCredentialsService.debugWriteLocalValueForTesting =
          (key, value) async {
            storage[key] = value;
          };
      ParticipantFitbitCredentialsService.debugDeleteLocalValueForTesting =
          (key) async {
            storage.remove(key);
          };
      ParticipantFitbitCredentialsService.debugContainsLocalKeyForTesting =
          (key) async => storage.containsKey(key);
      ParticipantFitbitCredentialsService.debugReadAllLocalValuesForTesting =
          () async => Map<String, String>.from(storage);
      ParticipantFitbitCredentialsService
              .debugServerCredentialsLoaderForTesting =
          ({required userId, required studyKey}) async => null;
      ParticipantFitbitCredentialsService
              .debugServerCredentialsUpserterForTesting =
          ({
            required userId,
            required studyKey,
            required credentialsJson,
          }) async {};
      ParticipantFitbitCredentialsService
              .debugServerCredentialsDeleterForTesting =
          ({required userId, required studyKey}) async {};
    });

    tearDown(ParticipantFitbitCredentialsService.debugResetTestingOverrides);

    test('server credentials are preferred and cached locally', () async {
      ParticipantFitbitCredentialsService
              .debugServerCredentialsLoaderForTesting =
          ({required userId, required studyKey}) async => serverCredentials;

      final loaded =
          await ParticipantFitbitCredentialsService.debugLoadCredentialsForTesting(
            'study-1',
          );

      expect(loaded?.userID, 'server-user');
      expect(
        storage['fitbit_credentials_user-1_study-1'],
        jsonEncode({
          'userID': 'server-user',
          'fitbitAccessToken': 'access-server-user',
          'fitbitRefreshToken': 'refresh-server-user',
        }),
      );
    });

    test('server credentials are returned when local caching throws', () async {
      ParticipantFitbitCredentialsService
              .debugServerCredentialsLoaderForTesting =
          ({required userId, required studyKey}) async => serverCredentials;
      ParticipantFitbitCredentialsService.debugWriteLocalValueForTesting =
          (key, value) => Future<void>.error(Exception('local cache failed'));

      final loaded =
          await ParticipantFitbitCredentialsService.debugLoadCredentialsForTesting(
            'study-1',
          );

      expect(loaded?.userID, 'server-user');
    });

    test('server returns no row so scoped local credentials are used', () async {
      storage['fitbit_credentials_user-1_study-1'] = jsonEncode({
        'userID': scopedCredentials.userID,
        'fitbitAccessToken': scopedCredentials.fitbitAccessToken,
        'fitbitRefreshToken': scopedCredentials.fitbitRefreshToken,
      });

      final loaded =
          await ParticipantFitbitCredentialsService.debugLoadCredentialsForTesting(
            'study-1',
          );

      expect(loaded?.userID, 'local-user');
    });

    test('server read throws so scoped local credentials are used', () async {
      storage['fitbit_credentials_user-1_study-1'] = jsonEncode({
        'userID': scopedCredentials.userID,
        'fitbitAccessToken': scopedCredentials.fitbitAccessToken,
        'fitbitRefreshToken': scopedCredentials.fitbitRefreshToken,
      });
      ParticipantFitbitCredentialsService
              .debugServerCredentialsLoaderForTesting =
          ({required userId, required studyKey}) async =>
              throw Exception('network');

      final loaded =
          await ParticipantFitbitCredentialsService.debugLoadCredentialsForTesting(
            'study-1',
          );

      expect(loaded?.userID, 'local-user');
    });

    test(
      'server upsert throws but scoped local credentials are still stored',
      () async {
        ParticipantFitbitCredentialsService
                .debugServerCredentialsUpserterForTesting =
            ({
              required userId,
              required studyKey,
              required credentialsJson,
            }) async => throw Exception('server down');

        await ParticipantFitbitCredentialsService.debugStoreCredentialsForTesting(
          scopedCredentials,
          'study-1',
        );

        expect(
          storage.containsKey('fitbit_credentials_user-1_study-1'),
          isTrue,
        );
      },
    );

    test('server upsert still occurs when local writing throws', () async {
      var upsertCalls = 0;
      ParticipantFitbitCredentialsService.debugWriteLocalValueForTesting =
          (key, value) => Future<void>.error(Exception('local failed'));
      ParticipantFitbitCredentialsService
              .debugServerCredentialsUpserterForTesting =
          ({
            required userId,
            required studyKey,
            required credentialsJson,
          }) async {
            upsertCalls++;
          };

      await ParticipantFitbitCredentialsService.debugStoreCredentialsForTesting(
        scopedCredentials,
        'study-1',
      );

      expect(upsertCalls, 1);
    });

    test('both storage failures are surfaced without exposing tokens', () async {
      ParticipantFitbitCredentialsService.debugWriteLocalValueForTesting =
          (key, value) => Future<void>.error(Exception('local failed'));
      ParticipantFitbitCredentialsService
              .debugServerCredentialsUpserterForTesting =
          ({
            required userId,
            required studyKey,
            required credentialsJson,
          }) async => throw Exception('server failed');

      try {
        await ParticipantFitbitCredentialsService.debugStoreCredentialsForTesting(
          scopedCredentials,
          'study-1',
        );
        fail('Expected storage failure');
      } catch (e) {
        expect(e, isA<FitbitCredentialStorageException>());
        expect(
          e.toString(),
          isNot(contains(scopedCredentials.fitbitAccessToken)),
        );
        expect(
          e.toString(),
          isNot(contains(scopedCredentials.fitbitRefreshToken)),
        );
      }
    });

    test(
      'authenticated users never consume legacy unscoped credentials',
      () async {
        storage['fitbit_credentials_study-1'] = jsonEncode({
          'userID': 'legacy-user',
          'fitbitAccessToken': 'legacy-access',
          'fitbitRefreshToken': 'legacy-refresh',
        });

        final loaded =
            await ParticipantFitbitCredentialsService.debugLoadCredentialsForTesting(
              'study-1',
            );

        expect(loaded, isNull);
        expect(storage.containsKey('fitbit_credentials_study-1'), isFalse);
      },
    );

    test(
      'participant A scoped value is never returned for participant B',
      () async {
        storage['fitbit_credentials_user-a_study-1'] = jsonEncode({
          'userID': 'participant-a',
          'fitbitAccessToken': 'access-a',
          'fitbitRefreshToken': 'refresh-a',
        });

        final loaded =
            await ParticipantFitbitCredentialsService.debugLoadCredentialsForTesting(
              'study-1',
            );

        expect(loaded, isNull);
      },
    );
  });
}

fitbitter.FitbitCredentials _credentials(String userId) {
  return fitbitter.FitbitCredentials(
    userID: userId,
    fitbitAccessToken: 'access-$userId',
    fitbitRefreshToken: 'refresh-$userId',
  );
}
