import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class PendingDeepLinkService {
  static const _inviteKey = 'pending_deferred_link_invite';
  static const _studyKey = 'pending_deferred_link_study';

  static Future<void> persist({String? studyId, String? inviteCode}) async {
    if (inviteCode != null) {
      await SecureStorage.write(_inviteKey, inviteCode);
      await SecureStorage.delete(_studyKey);
    } else if (studyId != null) {
      await SecureStorage.write(_studyKey, studyId);
      await SecureStorage.delete(_inviteKey);
    }
  }

  static Future<void> clear(AppState state) async {
    state.clearPendingDeepLink();
    state.selectedStudy = null;
    state.inviteCode = null;
    state.preselectedInterventionIds = null;
    await SecureStorage.delete(_inviteKey);
    await SecureStorage.delete(_studyKey);
  }

  static Future<void> clearStorage() async {
    await SecureStorage.delete(_inviteKey);
    await SecureStorage.delete(_studyKey);
  }

  static void storeInState({
    required AppState state,
    required Study study,
    String? inviteCode,
    List<String>? preselectedInterventionIds,
  }) {
    state.setPendingDeepLink(
      study: study,
      inviteCode: inviteCode,
      preselectedInterventionIds: preselectedInterventionIds,
    );
  }
}
