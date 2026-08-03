// ignore_for_file: avoid_setters_without_getters

import 'dart:convert';

import 'package:fitbitter/fitbitter.dart' as fitbitter;
import 'package:flutter/foundation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FitbitCredentialStorageException implements Exception {
  final bool localOperationFailed;
  final bool serverOperationFailed;

  const FitbitCredentialStorageException({
    required this.localOperationFailed,
    required this.serverOperationFailed,
  });

  @override
  String toString() =>
      'FitbitCredentialStorageException(localOperationFailed: $localOperationFailed, serverOperationFailed: $serverOperationFailed)';
}

class FitbitCredentialDeletionException implements Exception {
  final bool remoteDeletionFailed;
  final bool localDeletionFailed;

  const FitbitCredentialDeletionException({
    required this.remoteDeletionFailed,
    required this.localDeletionFailed,
  });

  @override
  String toString() =>
      'FitbitCredentialDeletionException(remoteDeletionFailed: $remoteDeletionFailed, localDeletionFailed: $localDeletionFailed)';
}

class ParticipantFitbitCredentialsService {
  static const String _fitbitCredentialsPrefix = 'fitbit_credentials_';
  static const String _participantFitbitTable =
      'participant_fitbit_credentials';

  static String? Function() _currentUserIdGetter = _defaultCurrentUserId;
  static Future<String?> Function(String) _readLocalValue = SecureStorage.read;
  static Future<void> Function(String, String) _writeLocalValue =
      SecureStorage.write;
  static Future<void> Function(String) _deleteLocalValue = SecureStorage.delete;
  static Future<bool> Function(String) _containsLocalKey =
      SecureStorage.containsKey;
  static Future<Map<String, String>> Function() _readAllLocalValues =
      SecureStorage.readAll;
  static Future<fitbitter.FitbitCredentials?> Function({
    required String userId,
    required String studyKey,
  })
  _serverCredentialsLoader = _loadCredentialsFromServer;
  static Future<void> Function({
    required String userId,
    required String studyKey,
    required Map<String, dynamic> credentialsJson,
  })
  _serverCredentialsUpserter = _upsertCredentialsOnServer;
  static Future<void> Function({
    required String userId,
    required String studyKey,
  })
  _serverCredentialsDeleter = _deleteCredentialsFromServer;

  static String _legacyLocalKey(String studyKey) =>
      '$_fitbitCredentialsPrefix$studyKey';

  static String _scopedLocalKey(String userId, String studyKey) =>
      '$_fitbitCredentialsPrefix${userId}_$studyKey';

  static String? _defaultCurrentUserId() =>
      Supabase.instance.client.auth.currentUser?.id;

  static Map<String, dynamic> _credentialsToJson(
    fitbitter.FitbitCredentials credentials,
  ) {
    return {
      'userID': credentials.userID,
      'fitbitAccessToken': credentials.fitbitAccessToken,
      'fitbitRefreshToken': credentials.fitbitRefreshToken,
    };
  }

  static fitbitter.FitbitCredentials _credentialsFromJson(
    Map<String, dynamic> jsonData,
  ) {
    return fitbitter.FitbitCredentials(
      userID: jsonData['userID'] as String,
      fitbitAccessToken: jsonData['fitbitAccessToken'] as String,
      fitbitRefreshToken: jsonData['fitbitRefreshToken'] as String,
    );
  }

  static Future<fitbitter.FitbitCredentials?> loadCredentials(
    String studyKey,
  ) async {
    final userId = _currentUserIdGetter();

    if (userId != null) {
      try {
        final serverCredentials = await _serverCredentialsLoader(
          userId: userId,
          studyKey: studyKey,
        );
        if (serverCredentials != null) {
          try {
            await _writeLocalValue(
              _scopedLocalKey(userId, studyKey),
              jsonEncode(_credentialsToJson(serverCredentials)),
            );
          } catch (e) {
            StudyULogger.warning(
              'Failed to cache participant Fitbit credentials locally: $e',
            );
          }
          try {
            if (await _containsLocalKey(_legacyLocalKey(studyKey))) {
              await _deleteLocalValue(_legacyLocalKey(studyKey));
            }
          } catch (e) {
            StudyULogger.warning(
              'Failed to delete legacy Fitbit credentials locally: $e',
            );
          }
          return serverCredentials;
        }
      } catch (e) {
        StudyULogger.error(
          'Failed to load participant Fitbit credentials from server: $e',
        );
      }

      String? scopedString;
      try {
        scopedString = await _readLocalValue(_scopedLocalKey(userId, studyKey));
      } catch (e) {
        StudyULogger.error(
          'Failed to load participant Fitbit credentials locally: $e',
        );
      }
      try {
        if (await _containsLocalKey(_legacyLocalKey(studyKey))) {
          await _deleteLocalValue(_legacyLocalKey(studyKey));
          StudyULogger.warning(
            'Discarded legacy Fitbit credentials for $studyKey after authenticated load because ownership cannot be verified.',
          );
        }
      } catch (e) {
        StudyULogger.warning(
          'Failed to delete legacy Fitbit credentials locally: $e',
        );
      }
      if (scopedString != null) {
        final jsonData = jsonDecode(scopedString) as Map<String, dynamic>;
        return _credentialsFromJson(jsonData);
      }
      return null;
    }

    try {
      final legacyString = await _readLocalValue(_legacyLocalKey(studyKey));
      if (legacyString != null) {
        final jsonData = jsonDecode(legacyString) as Map<String, dynamic>;
        return _credentialsFromJson(jsonData);
      }
    } catch (e) {
      StudyULogger.error('Failed to load Fitbit credentials: $e');
    }

    return null;
  }

  static Future<void> storeCredentials(
    fitbitter.FitbitCredentials? credentials,
    String studyKey,
  ) async {
    final userId = _currentUserIdGetter();

    if (credentials == null) {
      if (userId != null) {
        try {
          await _serverCredentialsDeleter(userId: userId, studyKey: studyKey);
        } catch (e) {
          StudyULogger.error(
            'Failed to delete participant Fitbit credentials from server: $e',
          );
        }
      }
      await _deleteLocalCredentials(studyKey, userId: userId);
      return;
    }

    final credentialsJson = _credentialsToJson(credentials);
    if (userId != null) {
      var localOperationFailed = false;
      var serverOperationFailed = false;

      try {
        await _writeLocalValue(
          _scopedLocalKey(userId, studyKey),
          jsonEncode(credentialsJson),
        );
      } catch (e) {
        localOperationFailed = true;
        StudyULogger.error(
          'Failed to store participant Fitbit credentials locally: $e',
        );
      }

      try {
        if (await _containsLocalKey(_legacyLocalKey(studyKey))) {
          await _deleteLocalValue(_legacyLocalKey(studyKey));
        }
      } catch (e) {
        StudyULogger.warning(
          'Failed to delete legacy Fitbit credentials locally: $e',
        );
      }

      try {
        await _serverCredentialsUpserter(
          userId: userId,
          studyKey: studyKey,
          credentialsJson: credentialsJson,
        );
      } catch (e) {
        serverOperationFailed = true;
        StudyULogger.error(
          'Failed to store participant Fitbit credentials on server: $e',
        );
      }

      if (localOperationFailed && serverOperationFailed) {
        throw const FitbitCredentialStorageException(
          localOperationFailed: true,
          serverOperationFailed: true,
        );
      }
      return;
    }

    await _writeLocalValue(
      _legacyLocalKey(studyKey),
      jsonEncode(credentialsJson),
    );
  }

  static Future<void> deleteFitbitCredentials(String studyKey) async {
    var remoteDeletionFailed = false;
    var localDeletionFailed = false;
    try {
      await deleteRemoteFitbitCredentials(studyKey);
    } on FitbitCredentialDeletionException catch (e) {
      remoteDeletionFailed = e.remoteDeletionFailed;
      localDeletionFailed = e.localDeletionFailed;
    }

    try {
      await clearLocalFallbackCredentialsForStudy(studyKey);
    } on FitbitCredentialDeletionException catch (e) {
      remoteDeletionFailed = remoteDeletionFailed || e.remoteDeletionFailed;
      localDeletionFailed = localDeletionFailed || e.localDeletionFailed;
    }

    if (remoteDeletionFailed || localDeletionFailed) {
      throw FitbitCredentialDeletionException(
        remoteDeletionFailed: remoteDeletionFailed,
        localDeletionFailed: localDeletionFailed,
      );
    }
  }

  static Future<void> deleteRemoteFitbitCredentials(String studyKey) async {
    final userId = _currentUserIdGetter();
    if (userId != null) {
      try {
        await _serverCredentialsDeleter(userId: userId, studyKey: studyKey);
      } catch (e) {
        StudyULogger.error(
          'Failed to delete participant Fitbit credentials from server: $e',
        );
        throw const FitbitCredentialDeletionException(
          remoteDeletionFailed: true,
          localDeletionFailed: false,
        );
      }
    }
  }

  static Future<void> clearLocalFallbackCredentialsForStudy(
    String studyKey,
  ) async {
    try {
      await _deleteLocalCredentials(studyKey, userId: _currentUserIdGetter());
    } catch (e) {
      StudyULogger.error(
        'Failed to delete participant Fitbit credentials locally: $e',
      );
      throw const FitbitCredentialDeletionException(
        remoteDeletionFailed: false,
        localDeletionFailed: true,
      );
    }
  }

  static Future<void> clearLocalFallbackCredentials() async {
    final storedValues = await _readAllLocalValues();
    for (final key in storedValues.keys) {
      if (key.startsWith(_fitbitCredentialsPrefix)) {
        await _deleteLocalValue(key);
      }
    }
  }

  static Future<fitbitter.FitbitCredentials?> _loadCredentialsFromServer({
    required String userId,
    required String studyKey,
  }) async {
    final response = await Supabase.instance.client
        .from(_participantFitbitTable)
        .select('fitbit_credentials')
        .eq('user_id', userId)
        .eq('study_id', studyKey)
        .maybeSingle();

    if (response == null) return null;

    final jsonData = response['fitbit_credentials'] as Map<String, dynamic>?;
    if (jsonData == null) return null;
    return _credentialsFromJson(jsonData);
  }

  static Future<void> _upsertCredentialsOnServer({
    required String userId,
    required String studyKey,
    required Map<String, dynamic> credentialsJson,
  }) async {
    await Supabase.instance.client.from(_participantFitbitTable).upsert({
      'user_id': userId,
      'study_id': studyKey,
      'fitbit_credentials': credentialsJson,
    });
  }

  static Future<void> _deleteCredentialsFromServer({
    required String userId,
    required String studyKey,
  }) async {
    await Supabase.instance.client
        .from(_participantFitbitTable)
        .delete()
        .eq('user_id', userId)
        .eq('study_id', studyKey);
  }

  static Future<void> _deleteLocalCredentials(
    String studyKey, {
    String? userId,
  }) async {
    final keysToDelete = <String>{_legacyLocalKey(studyKey)};
    final effectiveUserId = userId ?? _currentUserIdGetter();
    if (effectiveUserId != null) {
      keysToDelete.add(_scopedLocalKey(effectiveUserId, studyKey));
    }

    for (final key in keysToDelete) {
      if (await _containsLocalKey(key)) {
        await _deleteLocalValue(key);
      }
    }
  }

  @visibleForTesting
  static Future<fitbitter.FitbitCredentials?> debugLoadCredentialsForTesting(
    String studyKey,
  ) => loadCredentials(studyKey);

  @visibleForTesting
  static Future<void> debugStoreCredentialsForTesting(
    fitbitter.FitbitCredentials? credentials,
    String studyKey,
  ) => storeCredentials(credentials, studyKey);

  @visibleForTesting
  static set debugCurrentUserIdGetterForTesting(String? Function() value) {
    _currentUserIdGetter = value;
  }

  @visibleForTesting
  static set debugReadLocalValueForTesting(
    Future<String?> Function(String) value,
  ) {
    _readLocalValue = value;
  }

  @visibleForTesting
  static set debugWriteLocalValueForTesting(
    Future<void> Function(String, String) value,
  ) {
    _writeLocalValue = value;
  }

  @visibleForTesting
  static set debugDeleteLocalValueForTesting(
    Future<void> Function(String) value,
  ) {
    _deleteLocalValue = value;
  }

  @visibleForTesting
  static set debugContainsLocalKeyForTesting(
    Future<bool> Function(String) value,
  ) {
    _containsLocalKey = value;
  }

  @visibleForTesting
  static set debugReadAllLocalValuesForTesting(
    Future<Map<String, String>> Function() value,
  ) {
    _readAllLocalValues = value;
  }

  @visibleForTesting
  static set debugServerCredentialsLoaderForTesting(
    Future<fitbitter.FitbitCredentials?> Function({
      required String userId,
      required String studyKey,
    })
    value,
  ) {
    _serverCredentialsLoader = value;
  }

  @visibleForTesting
  static set debugServerCredentialsUpserterForTesting(
    Future<void> Function({
      required String userId,
      required String studyKey,
      required Map<String, dynamic> credentialsJson,
    })
    value,
  ) {
    _serverCredentialsUpserter = value;
  }

  @visibleForTesting
  static set debugServerCredentialsDeleterForTesting(
    Future<void> Function({required String userId, required String studyKey})
    value,
  ) {
    _serverCredentialsDeleter = value;
  }

  @visibleForTesting
  static void debugResetTestingOverrides() {
    _currentUserIdGetter = _defaultCurrentUserId;
    _readLocalValue = SecureStorage.read;
    _writeLocalValue = SecureStorage.write;
    _deleteLocalValue = SecureStorage.delete;
    _containsLocalKey = SecureStorage.containsKey;
    _readAllLocalValues = SecureStorage.readAll;
    _serverCredentialsLoader = _loadCredentialsFromServer;
    _serverCredentialsUpserter = _upsertCredentialsOnServer;
    _serverCredentialsDeleter = _deleteCredentialsFromServer;
  }
}
