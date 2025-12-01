import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model for recovery account response from Supabase RPC function
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

/// Service class for handling account recovery and study rejoining logic
class RejoinStudyService {
  /// Validates and decodes a recovery phrase to a user ID
  ///
  /// Tries English wordlist first, then German wordlist
  /// Returns the decoded user ID or throws an exception if invalid
  static BigInt decodeRecoveryPhrase(List<String> words) {
    try {
      return decode(words, wordlist: wordlistEn);
    } catch (e) {
      return decode(words, wordlist: wordlistDe);
    }
  }

  /// Converts BigInt user ID to UUID string format
  ///
  /// Example: BigInt(0x550e8400e29b41d4a716446655440000)
  ///       -> "550e8400-e29b-41d4-a716-446655440000"
  static String convertBigIntToUuid(BigInt userId) {
    final hexString = userId.toRadixString(16).padLeft(32, '0');
    return '${hexString.substring(0, 8)}-'
        '${hexString.substring(8, 12)}-'
        '${hexString.substring(12, 16)}-'
        '${hexString.substring(16, 20)}-'
        '${hexString.substring(20, 32)}';
  }

  /// Calls Supabase RPC function to recover account
  ///
  /// Takes user UUID and returns recovery result with credentials and
  /// optional subject ID
  static Future<RecoveryResult> recoverAccount(BigInt userId) async {
    try {
      final uuidString = convertBigIntToUuid(userId);
      final response = await Supabase.instance.client.rpc(
        'recover_account',
        params: {'p_user_id': uuidString},
      );

      if (response is Map<String, dynamic>) {
        return RecoveryResult.fromJson(response);
      } else {
        StudyULogger.warning('Unexpected response format: $response');
        return RecoveryResult(
          success: false,
          error: 'recovery_failed', // Will be translated by UI
        );
      }
    } catch (e) {
      StudyULogger.warning('RPC call failed: $e');
      return RecoveryResult(
        success: false,
        error: 'recovery_network_error', // Will be translated by UI
      );
    }
  }

  /// Validates that a subject is not deleted (user hasn't dropped from study)
  ///
  /// Returns true if subject is valid (not deleted), false otherwise
  static Future<bool> validateSubject(String subjectId) async {
    try {
      final subject = await SupabaseQuery.getById<StudySubject>(
        subjectId,
        selectedColumns: ['*'],
      );

      // Check if user has dropped from the study
      return !subject.isDeleted;
    } catch (e) {
      // If we can't fetch the subject, assume invalid
      return false;
    }
  }

  /// Orchestrates the complete recovery flow
  ///
  /// Steps:
  /// 1. Call recovery RPC function
  /// 2. Store new credentials
  /// 3. Sign in with new credentials
  /// 4. Validate subject (check is_deleted flag)
  /// 5. Store active subject ID if found and valid
  ///
  /// Returns RecoveryResult indicating success or failure
  static Future<RecoveryResult> performRecovery(BigInt userId) async {
    try {
      final result = await recoverAccount(userId);

      if (!result.success) {
        return result;
      }

      await storeFakeUserEmailAndPassword(result.email!, result.password!);

      final signInResult = await signInParticipant();
      if (!signInResult) {
        StudyULogger.warning('Sign in failed after recovery');
        return RecoveryResult(
          success: false,
          error: 'recovery_failed', // Will be translated by UI
        );
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
