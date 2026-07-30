import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class DashboardShowcaseStorage {
  static const _completedKey = 'dashboard_showcase_completed';

  const DashboardShowcaseStorage._();

  static Future<bool> isCompleted() async {
    return await SecureStorage.readBool(_completedKey) ?? false;
  }

  static Future<void> markCompleted() async {
    await SecureStorage.write(_completedKey, 'true');
  }

  static Future<void> reset() async {
    await SecureStorage.delete(_completedKey);
  }
}

class RecoveryPhraseStorage {
  static const _pendingKeyPrefix = 'recovery_phrase_pending';

  const RecoveryPhraseStorage._();

  static String _key(String subjectId) => '${_pendingKeyPrefix}_$subjectId';

  static Future<bool> isPending(String subjectId) async {
    return await SecureStorage.readBool(_key(subjectId)) ?? false;
  }

  static Future<void> markPending(String subjectId) async {
    await SecureStorage.write(_key(subjectId), 'true');
  }

  static Future<void> clearPending(String subjectId) async {
    await SecureStorage.delete(_key(subjectId));
  }
}
