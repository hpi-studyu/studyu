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

    final id = BigInt.parse(recoveryId.replaceAll('-', ''), radix: 16);
    return _cachedPhrase = encode(id);
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
    try {
      return decode(words, wordlist: wordlistEn);
    } catch (e) {
      return decode(words, wordlist: wordlistDe);
    }
  }

  static String convertBigIntToUuid(BigInt id) {
    final hexString = id.toRadixString(16).padLeft(32, '0');
    return '${hexString.substring(0, 8)}-'
        '${hexString.substring(8, 12)}-'
        '${hexString.substring(12, 16)}-'
        '${hexString.substring(16, 20)}-'
        '${hexString.substring(20, 32)}';
  }

  static Future<RecoveryResult> recoverAccount(BigInt recoveryId) async {
    try {
      final uuidString = convertBigIntToUuid(recoveryId);
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
