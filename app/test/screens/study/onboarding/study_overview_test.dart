import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/study_overview.dart';
import 'package:studyu_core/core.dart';

void main() {
  test('regular study overview returns to study selection', () {
    final state = AppState()..selectedStudy = Study('study-1', 'owner-1');

    expect(shouldReturnToStudySelection(state), isTrue);
  });

  test('invited study overview returns to terms', () {
    final state = AppState()
      ..setPendingDeepLink(
        study: Study('study-1', 'owner-1'),
        inviteCode: 'invite-1',
      );

    expect(shouldReturnToStudySelection(state), isFalse);
  });
}
