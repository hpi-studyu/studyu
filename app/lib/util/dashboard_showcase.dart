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
