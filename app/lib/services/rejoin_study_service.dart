import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecoveryResult {
  final bool success;
  final String? email;
  final String? password;
  final String? subjectId;
  final String? error;

  RecoveryResult({
    required this.success,
    this.email,
    this.password,
    this.subjectId,
    this.error,
  });

  factory RecoveryResult.fromJson(Map<String, dynamic> json) {
    return RecoveryResult(
      success: json['success'] as bool? ?? false,
      email: json['email'] as String?,
      password: json['password'] as String?,
      subjectId: json['subject_id'] as String?,
      error: json['error'] as String?,
    );
  }
}

class RejoinStudyService {
  static List<String>? _cachedPhrase;
  static String? _cachedRecoveryId;

  static void clearCache() {
    _cachedPhrase = null;
    _cachedRecoveryId = null;
  }

  static Future<List<String>?> getRecoveryPhrase() async {
    if (_cachedPhrase != null) return _cachedPhrase;

    final recoveryId = await getOrCreateRecoveryId();
    if (recoveryId == null) return null;

    final sanitizedId = _sanitizeUuid(recoveryId);
    if (sanitizedId == null) {
      StudyULogger.warning('Invalid recovery ID format');
      return null;
    }

    try {
      final id = BigInt.parse(sanitizedId, radix: 16);
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
    if (_cachedRecoveryId != null) return _cachedRecoveryId;

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
    } on ArgumentError catch (e) {
      // Check if error is due to word not found in English list
      final errorStr = e.toString();
      if (errorStr.contains('Invalid word') ||
          errorStr.contains('Checksum mismatch')) {
        // Try German wordlist
        try {
          final deWords = words.map((w) => w.toLowerCase().trim()).toList();
          return decode(deWords, wordlist: wordlistDe);
        } catch (_) {
          // German also failed, throw original English error
          rethrow;
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
        return RecoveryResult(
          success: false,
          error: 'invalid_recovery_id',
        );
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

      if (result.subjectId != null) {
        final isValid = await validateSubject(result.subjectId!);

        if (!isValid) {
          return RecoveryResult(
            success: true,
            email: result.email,
            password: result.password,
          );
        }

        await storeActiveSubjectId(result.subjectId!);
      }

      return result;
    } catch (e, stackTrace) {
      StudyULogger.warning('Error in performRecovery: $e\n$stackTrace');
      return RecoveryResult(success: false, error: 'recovery_network_error');
    }
  }
}
