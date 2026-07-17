import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecoveryResult {
  final bool success;
  final String? email;
  final String? password;
  final String? recoveryId;
  final String? subjectId;
  final String? error;

  RecoveryResult({
    required this.success,
    this.email,
    this.password,
    this.recoveryId,
    this.subjectId,
    this.error,
  });

  factory RecoveryResult.fromJson(Map<String, dynamic> json) {
    return RecoveryResult(
      success: json['success'] as bool? ?? false,
      email: json['email'] as String?,
      password: json['password'] as String?,
      recoveryId: json['recovery_id'] as String?,
      subjectId: json['subject_id'] as String?,
      error: json['error'] as String?,
    );
  }
}

class RestoreAccountService {
  static List<String>? _cachedPhrase;
  static String? _cachedRecoveryId;
  static String? _cachedUserId;
  static Future<String?> Function() _recoveryIdGetter = _fetchRecoveryId;
  static String? Function() _currentUserIdGetter = _currentUserId;

  static void clearCache() {
    _cachedPhrase = null;
    _cachedRecoveryId = null;
    _cachedUserId = null;
  }

  @visibleForTesting
  static Future<String?> Function() get debugRecoveryIdGetterForTesting =>
      _recoveryIdGetter;

  @visibleForTesting
  static set debugRecoveryIdGetterForTesting(
    Future<String?> Function() getter,
  ) {
    _recoveryIdGetter = getter;
  }

  @visibleForTesting
  static void debugResetRecoveryIdGetterForTesting() {
    _recoveryIdGetter = _fetchRecoveryId;
  }

  @visibleForTesting
  static String? Function() get debugCurrentUserIdGetterForTesting =>
      _currentUserIdGetter;

  @visibleForTesting
  static set debugCurrentUserIdGetterForTesting(String? Function() getter) {
    _currentUserIdGetter = getter;
  }

  @visibleForTesting
  static void debugResetCurrentUserIdGetterForTesting() {
    _currentUserIdGetter = _currentUserId;
  }

  static Future<List<String>?> getRecoveryPhrase() async {
    final currentUserId = _currentUserIdGetter();
    if (_cachedPhrase != null &&
        currentUserId != null &&
        _cachedUserId == currentUserId) {
      return _cachedPhrase;
    }

    final recoveryId = await getOrCreateRecoveryId();
    if (recoveryId == null) return null;

    final sanitizedId = _sanitizeUuid(recoveryId);
    if (sanitizedId == null) {
      StudyULogger.warning('Invalid recovery ID format');
      return null;
    }

    try {
      final id = BigInt.parse(sanitizedId, radix: 16);
      _cachedUserId = currentUserId;
      return _cachedPhrase = encode(id);
    } on FormatException catch (e) {
      StudyULogger.warning('Failed to parse recovery ID: $e');
      return null;
    }
  }

  /// Sanitizes a UUID string by removing hyphens and validating format
  /// Returns null if the UUID format is invalid
  static String? _sanitizeUuid(String uuid) {
    // Remove all hyphens and convert to lowercase
    final sanitized = uuid.replaceAll('-', '').toLowerCase().trim();

    // UUID without hyphens should be exactly 32 hex characters
    if (sanitized.length != 32) {
      return null;
    }

    // Validate hex characters only
    final validHex = RegExp(r'^[0-9a-f]+$');
    if (!validHex.hasMatch(sanitized)) {
      return null;
    }

    return sanitized;
  }

  static Future<String?> getOrCreateRecoveryId() async {
    final currentUserId = _currentUserIdGetter();
    if (_cachedRecoveryId != null &&
        currentUserId != null &&
        _cachedUserId == currentUserId) {
      return _cachedRecoveryId;
    }

    final recoveryId = await _recoveryIdGetter();
    if (recoveryId != null) {
      _cachedRecoveryId = recoveryId;
      _cachedUserId = currentUserId;
    }
    return recoveryId;
  }

  static Future<String?> _fetchRecoveryId() async {
    try {
      final response = await Supabase.instance.client.rpc(
        'get_or_create_recovery',
      );

      if (response is Map<String, dynamic> && response['success'] == true) {
        return _cachedRecoveryId = response['recovery_id'] as String?;
      } else {
        final error = response is Map ? response['error'] : 'Unknown error';
        StudyULogger.warning('Failed to get recovery_id: $error');
        return null;
      }
    } catch (e) {
      StudyULogger.warning('Error getting recovery_id: $e');
      return null;
    }
  }

  static String? _currentUserId() =>
      Supabase.instance.client.auth.currentUser?.id;

  static BigInt decodeRecoveryPhrase(List<String> words) {
    // Validate word count first
    if (words.length != RecoveryConstants.totalWordCount) {
      throw ArgumentError(
        'Expected ${RecoveryConstants.totalWordCount} words, got ${words.length}',
      );
    }

    // Try English wordlist first
    try {
      final enWords = words.map((w) => w.toLowerCase().trim()).toList();
      return decode(enWords, wordlist: wordlistEn);
    } catch (e) {
      if (e is! ArgumentError) rethrow;

      // Check if error is due to word not found in English list
      final errorStr = e.toString();
      if (errorStr.contains('Invalid word') ||
          errorStr.contains('Checksum mismatch')) {
        // Try German wordlist
        try {
          final deWords = words.map((w) => w.toLowerCase().trim()).toList();
          return decode(deWords, wordlist: wordlistDe);
        } catch (deError) {
          if (deError is! ArgumentError) rethrow;

          // German also failed, throw original English error
          throw e;
        }
      }
      rethrow;
    }
  }

  static String? convertBigIntToUuid(BigInt id) {
    // Validate the ID fits within 128 bits
    if (id < BigInt.zero || id > _max128BitValue) {
      StudyULogger.warning('Recovery ID out of valid range');
      return null;
    }

    final hexString = id.toRadixString(16).padLeft(32, '0');
    return '${hexString.substring(0, 8)}-'
        '${hexString.substring(8, 12)}-'
        '${hexString.substring(12, 16)}-'
        '${hexString.substring(16, 20)}-'
        '${hexString.substring(20, 32)}';
  }

  static final BigInt _max128BitValue = (BigInt.one << 128) - BigInt.one;

  static Future<RecoveryResult> recoverAccount(BigInt recoveryId) async {
    try {
      final uuidString = convertBigIntToUuid(recoveryId);
      if (uuidString == null) {
        return RecoveryResult(success: false, error: 'invalid_recovery_id');
      }
      final response = await Supabase.instance.client.rpc(
        'recover_account',
        params: {'p_recovery_id': uuidString},
      );

      if (response is Map<String, dynamic>) {
        return RecoveryResult.fromJson(response);
      } else {
        StudyULogger.warning('Unexpected response format: $response');
        return RecoveryResult(success: false, error: 'recovery_failed');
      }
    } catch (e) {
      StudyULogger.warning('RPC call failed: $e');
      return RecoveryResult(success: false, error: 'recovery_network_error');
    }
  }

  static Future<bool> validateSubject(String subjectId) async {
    try {
      final subject = await SupabaseQuery.getById<StudySubject>(
        subjectId,
        selectedColumns: ['*'],
      );
      return !subject.isDeleted;
    } catch (e) {
      return false;
    }
  }

  static Future<RecoveryResult> performRecovery(BigInt recoveryId) async {
    // Invalidate any cached recovery secret from a prior session before
    // establishing the recovered identity, so it cannot leak to the new
    // account via the static cache on a shared device.
    clearCache();
    try {
      final result = await recoverAccount(recoveryId);

      if (!result.success) {
        return result;
      }

      await storeFakeUserEmailAndPassword(result.email!, result.password!);

      final signInResult = await signInParticipant();
      if (!signInResult) {
        StudyULogger.warning('Sign in failed after recovery');
        return RecoveryResult(success: false, error: 'recovery_failed');
      }

      if (result.recoveryId != null) {
        _cachedRecoveryId = result.recoveryId;
        _cachedUserId = _currentUserIdGetter();
      }

      if (result.subjectId != null) {
        final isValid = await validateSubject(result.subjectId!);

        if (!isValid) {
          return RecoveryResult(
            success: true,
            email: result.email,
            password: result.password,
            recoveryId: result.recoveryId,
          );
        }

        await storeActiveSubjectId(result.subjectId!);
        await RecoveryPhraseStorage.markPending(result.subjectId!);
      }

      return result;
    } catch (e, stackTrace) {
      StudyULogger.warning('Error in performRecovery: $e\n$stackTrace');
      return RecoveryResult(success: false, error: 'recovery_network_error');
    }
  }
}
