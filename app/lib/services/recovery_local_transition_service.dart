// ignore_for_file: avoid_setters_without_getters

import 'package:flutter/foundation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecoveryLocalTransitionException implements Exception {
  const RecoveryLocalTransitionException();
}

class RecoveryTransitionSnapshot {
  final String? previousEmail;
  final String? previousPassword;
  final String? previousActiveSubjectId;

  const RecoveryTransitionSnapshot({
    required this.previousEmail,
    required this.previousPassword,
    required this.previousActiveSubjectId,
  });
}

class RecoveryLocalTransitionService {
  static Future<void> Function(String, String) _credentialStorer =
      _storeRecoveredCredentials;
  static Future<String?> Function() _storedEmailReader = getFakeUserEmail;
  static Future<String?> Function() _storedPasswordReader = getFakeUserPassword;
  static Future<String?> Function() _activeSubjectReader = getActiveSubjectId;
  static Future<void> Function(String) _storedEmailWriter = _writeStoredEmail;
  static Future<void> Function(String) _storedPasswordWriter =
      _writeStoredPassword;
  static Future<void> Function(String) _activeSubjectWriter =
      storeActiveSubjectId;
  static Future<void> Function() _storedEmailDeleter = _deleteStoredEmail;
  static Future<void> Function() _storedPasswordDeleter = _deleteStoredPassword;
  static Future<void> Function() _participantSignOutExecutor =
      _signOutRecoveredParticipant;
  static Future<void> Function() _activeSubjectClearer =
      deleteActiveStudyReference;

  static Future<RecoveryTransitionSnapshot> captureSnapshot() async {
    try {
      return RecoveryTransitionSnapshot(
        previousEmail: await _storedEmailReader(),
        previousPassword: await _storedPasswordReader(),
        previousActiveSubjectId: await _activeSubjectReader(),
      );
    } catch (e, stackTrace) {
      StudyULogger.warning(
        'Error capturing local recovery transition snapshot: $e\n$stackTrace',
      );
      throw const RecoveryLocalTransitionException();
    }
  }

  static Future<void> prepareForRecoveredAccount({
    required RecoveryTransitionSnapshot snapshot,
    required String email,
    required String password,
  }) async {
    try {
      await _credentialStorer(email, password);
      await _activeSubjectClearer();
    } catch (e, stackTrace) {
      StudyULogger.warning(
        'Error updating local recovery transition state: $e\n$stackTrace',
      );
      try {
        await _restoreStoredCredentials(snapshot);
      } catch (restoreError, restoreStackTrace) {
        StudyULogger.warning(
          'Error restoring previous local participant credentials: $restoreError\n$restoreStackTrace',
        );
      }
      await _restoreActiveSubject(snapshot.previousActiveSubjectId);
      try {
        await _participantSignOutExecutor();
      } catch (signOutError, signOutStackTrace) {
        StudyULogger.warning(
          'Error rolling back recovered participant session: $signOutError\n$signOutStackTrace',
        );
      }
      throw const RecoveryLocalTransitionException();
    }
  }

  static Future<void> _signOutRecoveredParticipant() async {
    await Supabase.instance.client.auth.signOut();
  }

  static Future<void> _writeStoredEmail(String email) async {
    await SecureStorage.write(userEmailKey, email);
  }

  static Future<void> _writeStoredPassword(String password) async {
    await SecureStorage.write(userPasswordKey, password);
  }

  static Future<void> _deleteStoredEmail() async {
    await SecureStorage.delete(userEmailKey);
  }

  static Future<void> _deleteStoredPassword() async {
    await SecureStorage.delete(userPasswordKey);
  }

  static Future<void> _storeRecoveredCredentials(
    String email,
    String password,
  ) async {
    await _storedEmailWriter(email);
    await _storedPasswordWriter(password);
  }

  static Future<void> _restoreStoredCredentials(
    RecoveryTransitionSnapshot snapshot,
  ) async {
    final emailRestored = await _restoreCredentialValue(
      value: snapshot.previousEmail,
      writer: _storedEmailWriter,
      deleter: _storedEmailDeleter,
    );
    final passwordRestored = await _restoreCredentialValue(
      value: snapshot.previousPassword,
      writer: _storedPasswordWriter,
      deleter: _storedPasswordDeleter,
    );
    if (emailRestored && passwordRestored) return;

    try {
      await _storedEmailDeleter();
      await _storedPasswordDeleter();
    } catch (e, stackTrace) {
      StudyULogger.warning(
        'Error deleting incomplete local participant credentials during rollback: $e\n$stackTrace',
      );
    }
  }

  static Future<bool> _restoreCredentialValue({
    required String? value,
    required Future<void> Function(String) writer,
    required Future<void> Function() deleter,
  }) async {
    try {
      if (value == null) {
        await deleter();
      } else {
        await writer(value);
      }
      return true;
    } catch (e, stackTrace) {
      StudyULogger.warning(
        'Error restoring local participant credential value: $e\n$stackTrace',
      );
      return false;
    }
  }

  static Future<void> _restoreActiveSubject(
    String? previousActiveSubjectId,
  ) async {
    try {
      if (previousActiveSubjectId == null) {
        await _activeSubjectClearer();
      } else {
        await _activeSubjectWriter(previousActiveSubjectId);
      }
    } catch (e, stackTrace) {
      StudyULogger.warning(
        'Error restoring previous active subject reference: $e\n$stackTrace',
      );
    }
  }

  @visibleForTesting
  static Future<void> Function(String, String)
  get debugCredentialStorerForTesting => _credentialStorer;

  @visibleForTesting
  static set debugCredentialStorerForTesting(
    Future<void> Function(String, String) value,
  ) {
    _credentialStorer = value;
  }

  @visibleForTesting
  static Future<String?> Function() get debugStoredEmailReaderForTesting =>
      _storedEmailReader;

  @visibleForTesting
  static set debugStoredEmailReaderForTesting(
    Future<String?> Function() value,
  ) {
    _storedEmailReader = value;
  }

  @visibleForTesting
  static Future<String?> Function() get debugStoredPasswordReaderForTesting =>
      _storedPasswordReader;

  @visibleForTesting
  static set debugStoredPasswordReaderForTesting(
    Future<String?> Function() value,
  ) {
    _storedPasswordReader = value;
  }

  @visibleForTesting
  static set debugActiveSubjectReaderForTesting(
    Future<String?> Function() value,
  ) {
    _activeSubjectReader = value;
  }

  @visibleForTesting
  static Future<void> Function(String) get debugStoredEmailWriterForTesting =>
      _storedEmailWriter;

  @visibleForTesting
  static set debugStoredEmailWriterForTesting(
    Future<void> Function(String) value,
  ) {
    _storedEmailWriter = value;
  }

  @visibleForTesting
  static Future<void> Function(String)
  get debugStoredPasswordWriterForTesting => _storedPasswordWriter;

  @visibleForTesting
  static set debugStoredPasswordWriterForTesting(
    Future<void> Function(String) value,
  ) {
    _storedPasswordWriter = value;
  }

  @visibleForTesting
  static set debugActiveSubjectWriterForTesting(
    Future<void> Function(String) value,
  ) {
    _activeSubjectWriter = value;
  }

  @visibleForTesting
  static Future<void> Function() get debugStoredEmailDeleterForTesting =>
      _storedEmailDeleter;

  @visibleForTesting
  static set debugStoredEmailDeleterForTesting(Future<void> Function() value) {
    _storedEmailDeleter = value;
  }

  @visibleForTesting
  static Future<void> Function() get debugStoredPasswordDeleterForTesting =>
      _storedPasswordDeleter;

  @visibleForTesting
  static set debugStoredPasswordDeleterForTesting(
    Future<void> Function() value,
  ) {
    _storedPasswordDeleter = value;
  }

  @visibleForTesting
  static Future<void> Function()
  get debugParticipantSignOutExecutorForTesting => _participantSignOutExecutor;

  @visibleForTesting
  static set debugParticipantSignOutExecutorForTesting(
    Future<void> Function() value,
  ) {
    _participantSignOutExecutor = value;
  }

  @visibleForTesting
  static Future<void> Function() get debugActiveSubjectClearerForTesting =>
      _activeSubjectClearer;

  @visibleForTesting
  static set debugActiveSubjectClearerForTesting(
    Future<void> Function() value,
  ) {
    _activeSubjectClearer = value;
  }

  @visibleForTesting
  static void debugResetTestingOverrides() {
    _credentialStorer = _storeRecoveredCredentials;
    _storedEmailReader = getFakeUserEmail;
    _storedPasswordReader = getFakeUserPassword;
    _activeSubjectReader = getActiveSubjectId;
    _storedEmailWriter = _writeStoredEmail;
    _storedPasswordWriter = _writeStoredPassword;
    _activeSubjectWriter = storeActiveSubjectId;
    _storedEmailDeleter = _deleteStoredEmail;
    _storedPasswordDeleter = _deleteStoredPassword;
    _participantSignOutExecutor = _signOutRecoveredParticipant;
    _activeSubjectClearer = deleteActiveStudyReference;
  }
}
