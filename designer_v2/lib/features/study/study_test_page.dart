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
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyTestScreen extends ConsumerStatefulWidget {
  const StudyTestScreen(this.studyId, {Key? key}) : super(key: key);

class StudyTestScreen extends StudyPageWidget {
  const StudyTestScreen(studyId, {Key? key}) : super(studyId, key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyTestControllerProvider(studyId));
    final frameController =
        ref.watch(studyTestPlatformControllerProvider(studyId));
    final formViewModel = ref.watch(studyTestValidatorProvider(studyId));

    load().then((value) => value ? null : showHelp(ref));

    final frameControls = Column(
      children: [
        const SizedBox(height: 24.0),
        Text(
            "This is the preview mode.\nPress reset to "
                    "remove the test progress and start over again."
                .hardcoded,
            textAlign: TextAlign.center),
        // tr.this_preview_mode+ tr.press_reset todo not sure if translation is still correct
        const SizedBox(height: 12.0),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton.icon(
            icon: const Icon(Icons.restart_alt),
            label: Text(tr.reset),
            onPressed: (!state.canTest)
                ? null
                : () {
                    frameController!.sendCmd("reset");
                  },
          ),
          TextButton.icon(
            icon: const Icon(Icons.open_in_new_sharp),
            label: Text(tr.open_in_tab),
            onPressed: (!state.canTest)
                ? null
                : () {
                    frameController!.openNewPage();
                  },
          ),
        ]),
      ],
    );

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ReactiveForm(
              formGroup: formViewModel.form,
              child: ReactiveFormConsumer(builder: (context, form, child) {
                if (formViewModel.form.hasErrors) {
                  return const DisabledFrame();
                }
                return Column(
                  children: [frameController!.frameWidget, frameControls],
                );
              })),
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

  showHelp(WidgetRef ref) {
    ref
        .read(notificationServiceProvider)
        .show(Notifications.welcomeTestMode, actions: [
      NotificationAction(
          label: "Got it!".hardcoded,
          onSelect: Future.value,
          isDestructive: false),
    ]);
    save();
  }
}
