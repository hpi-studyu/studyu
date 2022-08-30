import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/services/notifications.dart';

class StudyTestScreen extends StudyPageWidget {
  const StudyTestScreen(studyId, {Key? key}) : super(studyId, key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyTestControllerProvider(studyId));
    final frameController = ref.watch(
        studyTestPlatformControllerProvider(studyId));
    frameController.navigate();
    load().then((hasHelped) => !hasHelped ? showHelp(ref, context) : null);

    return Stack(
      //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("In the test mode you can preview your study.".hardcoded),
                const SizedBox(height: 12.0),
                Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.help),
                        label: Text("How does this work?".hardcoded),
                        onPressed: () => showHelp(ref, context),
                      ),
                    ]
                ),
                const SizedBox(height: 12.0),
                Text("Choose a page:".hardcoded),
                const SizedBox(height: 12.0),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text("Study Overview".hardcoded), // questionnaire?
                  onPressed: (!state.canTest) ? null : () {
                    frameController.navigate();
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text("Eligibility Check".hardcoded), // questionnaire?
                  onPressed: (!state.canTest) ? null : () {
                    frameController.navigate(page: "eligibilityCheck");
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text("Intervention Selection".hardcoded),
                  onPressed: (!state.canTest) ? null : () {
                    frameController.navigate(page: "interventionSelection");
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text("Consent".hardcoded),
                  onPressed: (!state.canTest) ? null : () {
                    frameController.navigate(page: "consent");
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text("Dashboard".hardcoded),
                  onPressed: (!state.canTest) ? null : () {
                    frameController.navigate(page: "dashboard");
                  },
                ),
              ]
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                    children: [
                      PreviewFrame(studyId, frameController: frameController, state: state),
                    ]
                ),
              ]
          ),
        ]
    );
  }

  @override
  Widget? banner(BuildContext context, WidgetRef ref) {
    final formViewModel = ref.watch(studyTestValidatorProvider(studyId));
    if (!formViewModel.form.hasErrors) {
      return null;
    }
    return BannerBox(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextParagraph(
              text: "The preview is unavailable until you update the "
                  "following information:".hardcoded,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ReactiveForm(
                formGroup: formViewModel.form,
                child: ReactiveFormConsumer(builder: (context, form, child) {
                  return TextParagraph(
                    text: form.validationErrorSummary,
                  );
                })),
          ]),
      style: BannerStyle.warning,
    );
  }

  Future<bool> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool? visited = prefs.getBool('testScreenVisited');
      if (visited != null) {
        return visited;
      }
    } catch (e) {
      rethrow;
    }
    return false;
  }

  Future<bool> save() async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('testScreenVisited', true);
      return true;
    });
    return false;
  }

  showHelp(WidgetRef ref, BuildContext context) {
    ref.read(notificationServiceProvider).show(
        Notifications.welcomeTestMode(context), actions: [
      NotificationAction(
          label: "Got it!".hardcoded,
          onSelect: Future.value,
          isDestructive: false),
    ]);
    save();
  }
}
