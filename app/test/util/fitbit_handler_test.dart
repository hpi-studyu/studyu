import 'dart:convert';

import 'package:fitbitter/fitbitter.dart' as fitbitter;
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/util/fitbit_handler.dart';

void main() {
  group('FitbitHandler', () {
    late Map<String, String> storage;
    late fitbitter.FitbitCredentials serverCredentials;
    late fitbitter.FitbitCredentials scopedCredentials;

    setUp(() {
      storage = {};
      serverCredentials = _credentials('server-user');
      scopedCredentials = _credentials('local-user');

      FitbitHandler.debugCurrentUserIdGetterForTesting = () => 'user-1';
      FitbitHandler.debugReadLocalValueForTesting = (key) async => storage[key];
      FitbitHandler.debugWriteLocalValueForTesting = (key, value) async {
        storage[key] = value;
      };
      FitbitHandler.debugDeleteLocalValueForTesting = (key) async {
        storage.remove(key);
      };
      FitbitHandler.debugContainsLocalKeyForTesting = (key) async =>
          storage.containsKey(key);
      FitbitHandler.debugReadAllLocalValuesForTesting = () async =>
          Map<String, String>.from(storage);
      FitbitHandler.debugServerCredentialsLoaderForTesting =
          ({required userId, required studyKey}) async => null;
      FitbitHandler.debugServerCredentialsUpserterForTesting =
          ({
            required userId,
            required studyKey,
            required credentialsJson,
          }) async {};
      FitbitHandler.debugServerCredentialsDeleterForTesting =
          ({required userId, required studyKey}) async {};
    });

    tearDown(FitbitHandler.debugResetTestingOverrides);

    test('server credentials are preferred and cached locally', () async {
      FitbitHandler.debugServerCredentialsLoaderForTesting =
          ({required userId, required studyKey}) async => serverCredentials;

      final loaded = await FitbitHandler.debugLoadCredentialsForTesting(
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

    test(
      'server returns no row so scoped local credentials are used',
      () async {
        storage['fitbit_credentials_user-1_study-1'] = jsonEncode({
          'userID': scopedCredentials.userID,
          'fitbitAccessToken': scopedCredentials.fitbitAccessToken,
          'fitbitRefreshToken': scopedCredentials.fitbitRefreshToken,
        });

        final loaded = await FitbitHandler.debugLoadCredentialsForTesting(
          'study-1',
        );

        expect(loaded?.userID, 'local-user');
      },
    );

    test('server read throws so scoped local credentials are used', () async {
      storage['fitbit_credentials_user-1_study-1'] = jsonEncode({
        'userID': scopedCredentials.userID,
        'fitbitAccessToken': scopedCredentials.fitbitAccessToken,
        'fitbitRefreshToken': scopedCredentials.fitbitRefreshToken,
      });
      FitbitHandler.debugServerCredentialsLoaderForTesting =
          ({required userId, required studyKey}) async =>
              throw Exception('network');

      final loaded = await FitbitHandler.debugLoadCredentialsForTesting(
        'study-1',
      );

      expect(loaded?.userID, 'local-user');
    });

    test(
      'server upsert throws but scoped local credentials are still stored',
      () async {
        FitbitHandler.debugServerCredentialsUpserterForTesting =
            ({
              required userId,
              required studyKey,
              required credentialsJson,
            }) async => throw Exception('server down');

        await FitbitHandler.debugStoreCredentialsForTesting(
          scopedCredentials,
          'study-1',
        );

        expect(
          storage.containsKey('fitbit_credentials_user-1_study-1'),
          isTrue,
        );
      },
    );

    test(
      'authenticated users never consume legacy unscoped credentials',
      () async {
        storage['fitbit_credentials_study-1'] = jsonEncode({
          'userID': 'legacy-user',
          'fitbitAccessToken': 'legacy-access',
          'fitbitRefreshToken': 'legacy-refresh',
        });

        final loaded = await FitbitHandler.debugLoadCredentialsForTesting(
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

        final loaded = await FitbitHandler.debugLoadCredentialsForTesting(
          'study-1',
        );

        expect(loaded, isNull);
      },
    );

    test('local cleanup removes participant fitbit fallback keys', () async {
      storage['fitbit_credentials_user-1_study-1'] = 'one';
      storage['fitbit_credentials_user-2_study-2'] = 'two';
      storage['fitbit_credentials_study-3'] = 'three';

      await FitbitHandler.clearLocalFallbackCredentials();

      expect(storage, isEmpty);
    });
  });
}

fitbitter.FitbitCredentials _credentials(String userId) {
  return fitbitter.FitbitCredentials(
    userID: userId,
    fitbitAccessToken: 'access-$userId',
    fitbitRefreshToken: 'refresh-$userId',
  );
}
