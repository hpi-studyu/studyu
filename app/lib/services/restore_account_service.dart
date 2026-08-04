import 'package:flutter/foundation.dart';
import 'package:studyu_app/services/participant_fitbit_credentials_service.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/services/recovery_local_transition_service.dart';
import 'package:studyu_app/util/cache.dart';
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

class RestoreAccountService {
  static List<String>? _cachedPhrase;
  static String? _cachedRecoveryId;
  static String? _cachedUserId;
  static Future<String?> Function() _recoveryIdGetter = _fetchRecoveryId;
  static Future<String?> Function() _recoveryIdRotator = _rotateRecoveryId;
  static String? Function() _currentUserIdGetter = _currentUserId;
  static Future<RecoveryResult> Function(BigInt) _recoverAccountExecutor =
      recoverAccount;
  static Future<bool> Function(String, String) _participantSignInExecutor =
      _signInRecoveredParticipant;
  static Future<bool> Function(String) _subjectValidator = validateSubject;
  static Future<void> Function(String) _activeSubjectStorer =
      storeActiveSubjectId;
  static Future<void> Function(String?, String?) _participantStateCleanup =
      _cleanupParticipantStateForRecovery;

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
  static Future<String?> Function() get debugRecoveryIdRotatorForTesting =>
      _recoveryIdRotator;

  @visibleForTesting
  static set debugRecoveryIdRotatorForTesting(
    Future<String?> Function() rotator,
  ) {
    _recoveryIdRotator = rotator;
  }

  @visibleForTesting
  static void debugResetRecoveryIdRotatorForTesting() {
    _recoveryIdRotator = _rotateRecoveryId;
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

  @visibleForTesting
  static Future<RecoveryResult> Function(BigInt)
  get debugRecoverAccountExecutorForTesting => _recoverAccountExecutor;

  @visibleForTesting
  static set debugRecoverAccountExecutorForTesting(
    Future<RecoveryResult> Function(BigInt) executor,
  ) {
    _recoverAccountExecutor = executor;
  }

  @visibleForTesting
  static void debugResetRecoverAccountExecutorForTesting() {
    _recoverAccountExecutor = recoverAccount;
  }

  @visibleForTesting
  static Future<bool> Function(String, String)
  get debugParticipantSignInExecutorForTesting => _participantSignInExecutor;

  @visibleForTesting
  static set debugParticipantSignInExecutorForTesting(
    Future<bool> Function(String, String) executor,
  ) {
    _participantSignInExecutor = executor;
  }

  @visibleForTesting
  static void debugResetParticipantSignInExecutorForTesting() {
    _participantSignInExecutor = _signInRecoveredParticipant;
  }

  @visibleForTesting
  static Future<bool> Function(String) get debugSubjectValidatorForTesting =>
      _subjectValidator;

  @visibleForTesting
  static set debugSubjectValidatorForTesting(
    Future<bool> Function(String) validator,
  ) {
    _subjectValidator = validator;
  }

  @visibleForTesting
  static void debugResetSubjectValidatorForTesting() {
    _subjectValidator = validateSubject;
  }

  @visibleForTesting
  static Future<void> Function(String) get debugActiveSubjectStorerForTesting =>
      _activeSubjectStorer;

  @visibleForTesting
  static set debugActiveSubjectStorerForTesting(
    Future<void> Function(String) storer,
  ) {
    _activeSubjectStorer = storer;
  }

  @visibleForTesting
  static void debugResetActiveSubjectStorerForTesting() {
    _activeSubjectStorer = storeActiveSubjectId;
  }

  @visibleForTesting
  static Future<void> Function(String?, String?)
  get debugParticipantStateCleanupForTesting => _participantStateCleanup;

  @visibleForTesting
  static set debugParticipantStateCleanupForTesting(
    Future<void> Function(String?, String?) cleanup,
  ) {
    _participantStateCleanup = cleanup;
  }

  @visibleForTesting
  static void debugResetParticipantStateCleanupForTesting() {
    _participantStateCleanup = _cleanupParticipantStateForRecovery;
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

  static String? _sanitizeUuid(String uuid) {
    final sanitized = uuid.replaceAll('-', '').toLowerCase().trim();
    if (sanitized.length != 32) return null;
    if (!RegExp(r'^[0-9a-f]+$').hasMatch(sanitized)) return null;
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
      }
      final error = response is Map ? response['error'] : 'Unknown error';
      StudyULogger.warning('Failed to get recovery_id: $error');
      return null;
    } catch (e) {
      StudyULogger.warning('Error getting recovery_id: $e');
      return null;
    }
  }

  static Future<List<String>?> rotateRecoveryPhrase() async {
    clearCache();
    final recoveryId = await _recoveryIdRotator();
    final sanitizedId = recoveryId == null ? null : _sanitizeUuid(recoveryId);
    if (sanitizedId == null) return null;

    try {
      final phrase = encode(BigInt.parse(sanitizedId, radix: 16));
      _cachedRecoveryId = recoveryId;
      _cachedPhrase = phrase;
      _cachedUserId = _currentUserIdGetter();
      return phrase;
    } on FormatException catch (e) {
      StudyULogger.warning('Failed to parse rotated recovery ID: $e');
      return null;
    }
  }

  static Future<String?> _rotateRecoveryId() async {
    try {
      final response = await Supabase.instance.client.rpc('rotate_recovery_id');
      if (response is String) return response;
      StudyULogger.warning('Unexpected rotate_recovery_id response');
      return null;
    } catch (e) {
      StudyULogger.warning('Error rotating recovery_id: $e');
      return null;
    }
  }

  static String? _currentUserId() =>
      Supabase.instance.client.auth.currentUser?.id;

  static Future<bool> _signInRecoveredParticipant(
    String email,
    String password,
  ) async {
    try {
      final authResponse = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      return authResponse.session != null;
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
      return false;
    }
  }

  static Future<void> _cleanupParticipantStateForRecovery(
    String? recoveredUserId,
    String? recoveredSubjectId,
  ) async {
    clearCache();
    await Cache.clearRecoverySubjectCaches(
      recoveredUserId: recoveredUserId,
      recoveredSubjectId: recoveredSubjectId,
    );
    await PendingDeepLinkService.clearStorage();
    await ParticipantFitbitCredentialsService.clearLocalFallbackCredentialsForRecovery(
      recoveredUserId,
    );
  }

  static BigInt decodeRecoveryPhrase(List<String> words) {
    if (words.length != RecoveryConstants.totalWordCount) {
      throw ArgumentError(
        'Expected ${RecoveryConstants.totalWordCount} words, got ${words.length}',
      );
    }

    try {
      final enWords = words.map((w) => w.toLowerCase().trim()).toList();
      return decode(enWords, wordlist: wordlistEn);
    } catch (e) {
      if (e is! ArgumentError) rethrow;
      final errorStr = e.toString();
      if (!errorStr.contains('Invalid word') &&
          !errorStr.contains('Checksum mismatch')) {
        rethrow;
      }

      try {
        final deWords = words.map((w) => w.toLowerCase().trim()).toList();
        return decode(deWords, wordlist: wordlistDe);
      } catch (deError) {
        if (deError is! ArgumentError) rethrow;
        throw e;
      }
    }
  }

  static String? convertBigIntToUuid(BigInt id) {
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
      }
      StudyULogger.warning('Unexpected response format: $response');
      return RecoveryResult(success: false, error: 'recovery_failed');
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
    } catch (_) {
      return false;
    }
  }

  static Future<RecoveryResult> performRecovery(BigInt recoveryId) async {
    try {
      final result = await _recoverAccountExecutor(recoveryId);
      if (!result.success) return result;

      final recoveredEmail = result.email;
      final recoveredPassword = result.password;
      if (recoveredEmail == null || recoveredPassword == null) {
        StudyULogger.warning('Recovery result missing credentials');
        return RecoveryResult(success: false, error: 'recovery_failed');
      }

      final RecoveryTransitionSnapshot transitionSnapshot;
      try {
        transitionSnapshot =
            await RecoveryLocalTransitionService.captureSnapshot();
      } on RecoveryLocalTransitionException {
        return RecoveryResult(
          success: false,
          error: 'recovery_local_persistence_failed',
        );
      }

      final signInResult = await _participantSignInExecutor(
        recoveredEmail,
        recoveredPassword,
      );
      if (!signInResult) {
        StudyULogger.warning('Sign in failed after recovery');
        return RecoveryResult(success: false, error: 'recovery_failed');
      }

      final recoveredUserId = _currentUserIdGetter();
      final recoveredSubjectId = result.subjectId;

      try {
        await RecoveryLocalTransitionService.prepareForRecoveredAccount(
          snapshot: transitionSnapshot,
          email: recoveredEmail,
          password: recoveredPassword,
        );
      } on RecoveryLocalTransitionException {
        return RecoveryResult(
          success: false,
          error: 'recovery_local_persistence_failed',
        );
      }

      final validRecoveredSubjectId =
          recoveredSubjectId != null &&
              await _subjectValidator(recoveredSubjectId)
          ? recoveredSubjectId
          : null;

      try {
        await _participantStateCleanup(
          recoveredUserId,
          validRecoveredSubjectId,
        );
      } catch (e, stackTrace) {
        StudyULogger.warning(
          'Error cleaning up participant state after recovery sign in: $e\n$stackTrace',
        );
        return RecoveryResult(success: false, error: 'recovery_cleanup_failed');
      }

      if (validRecoveredSubjectId == null) {
        return RecoveryResult(
          success: true,
          email: result.email,
          password: result.password,
        );
      }

      await _activeSubjectStorer(validRecoveredSubjectId);
      return result;
    } catch (e, stackTrace) {
      StudyULogger.warning('Error in performRecovery: $e\n$stackTrace');
      return RecoveryResult(success: false, error: 'recovery_network_error');
    }
  }
}
