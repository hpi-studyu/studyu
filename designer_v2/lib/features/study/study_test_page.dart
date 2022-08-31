import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class StudyTestScreen extends StudyPageWidget {
  const StudyTestScreen(studyId, {Key? key}) : super(studyId, key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyTestControllerProvider(studyId));
    final frameController = ref.watch(
        studyTestPlatformControllerProvider(studyId));
    frameController.generateUrl();
    frameController.activate();
    load().then((hasHelped) => !hasHelped ? showHelp(ref, context) : null);

    return Stack(
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
                    frameController.navigate(route: "eligibilityCheck");
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text("Intervention Selection".hardcoded),
                  onPressed: (!state.canTest) ? null : () {
                    frameController.navigate(route: "interventionSelection");
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text("Consent".hardcoded),
                  onPressed: (!state.canTest) ? null : () {
                    frameController.navigate(route: "consent");
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text("Dashboard".hardcoded),
                  onPressed: (!state.canTest) ? null : () {
                    frameController.navigate(route: "dashboard");
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
    final theme = Theme.of(context);
    Widget previewHelp = StandardDialog(
        titleText: "Test your study!".hardcoded,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextParagraph(text: "This page allows you to experience your study like one of your study's participants, so that you can tailor the design to your needs and verify everything works correctly.\n"),
            Align(alignment: Alignment.centerLeft, child: Text("\u{2b50} Pro Tips\n", style: theme.textTheme.headline5)),
            Align(alignment: Alignment.centerLeft, child: TextParagraph(span: [
              const TextSpan(text: "• Use the menu in the top-left to quickly preview and jump to different parts of your study (e.g. surveys)\n"
                  "• To get a fresh experience, you can reset all data and enroll as a new test user\n"
                  "• You can also "),
              TextSpan(
                text: 'download the StudyU app',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launchUrl(Uri.parse('https://github.com/hpi-studyu/studyu#app-stores')),
              ),
              const TextSpan(text: " on your phone for testing\n"),
            ])),
            Align(alignment: Alignment.centerLeft, child: Text("\u{26a0} Please note\n", style: theme.textTheme.headline5)),
            Align(alignment: Alignment.centerLeft, child: TextParagraph(text: "• All test users and their data will be reset one you launch the study\n")),
          ],
        ),
      actionButtons: [
        PrimaryButton(
          text: "Start testing".hardcoded,
          icon: null,
          onPressed: () => Navigator.pop(context),
        )
      ],
      maxWidth: 650,
      minWidth: 550,
    );
    showDialog(
      context: context,
      barrierColor: ThemeConfig.modalBarrierColor(theme),
      builder: (context) => previewHelp,
    );
    save();
  }
}
