import 'package:studyu_mcp/ui/app/app_ui_flow.dart';
import 'package:test/test.dart';

void main() {
  test('completes onboarding and legal steps', () async {
    final visibleKeys = {StudyUAppKey.onboardingNext};
    var introPage = 0;
    var legalFormShown = false;

    await StudyUAppUiFlow(
      shortTimeout: Duration.zero,
      routeTimeout: Duration.zero,
      finalTimeout: Duration.zero,
      waitForKey: (key, {required timeout}) async => visibleKeys.contains(key),
      tapKey: (key) async {
        switch (key) {
          case StudyUAppKey.onboardingNext:
            if (++introPage == 4) {
              visibleKeys
                ..remove(key)
                ..add(StudyUAppKey.onboardingDone);
            }
          case StudyUAppKey.onboardingDone:
            visibleKeys
              ..remove(key)
              ..add(StudyUAppKey.welcomeGetStarted);
          case StudyUAppKey.welcomeGetStarted:
            visibleKeys
              ..remove(key)
              ..add(StudyUAppKey.termsContinue);
          case StudyUAppKey.termsContinue:
            if (legalFormShown) {
              visibleKeys
                ..clear()
                ..add(StudyUAppKey.studySelectionList);
            } else {
              legalFormShown = true;
              visibleKeys.addAll({
                StudyUAppKey.termsCheckbox,
                StudyUAppKey.privacyCheckbox,
              });
            }
          case StudyUAppKey.termsCheckbox:
          case StudyUAppKey.privacyCheckbox:
            visibleKeys.remove(key);
        }
      },
    ).completeOnboardingToStudyList();

    expect(visibleKeys, contains(StudyUAppKey.studySelectionList));
  });
}
