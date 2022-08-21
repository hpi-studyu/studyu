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
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/services/notifications.dart';

class StudyTestScreen extends StudyPageWidget {
  final StudyFormRouteArgs? routeArgs;
  const StudyTestScreen(studyId, {this.routeArgs, Key? key}) : super(studyId, key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyTestControllerProvider(studyId));
    final frameController = ref.watch(studyTestPlatformControllerProvider(studyId));
    final formViewModel = ref.watch(studyTestValidatorProvider(studyId));

    frameController.listen();

    if (routeArgs is InterventionFormRouteArgs ) {
      final ifra = routeArgs as InterventionFormRouteArgs;
      frameController.navigatePage('intervention', extra: ifra.interventionId);
    } else if (routeArgs is MeasurementFormRouteArgs) {
      final mfra = routeArgs as MeasurementFormRouteArgs;
      frameController.navigatePage('observation', extra: mfra.measurementId);
    }

    load().then((hasHelped) => !hasHelped ? showHelp(ref) : null);

    final frameControls = Column(
      children: [
        const SizedBox(height: 24.0),
        Text("This is the preview mode.\nPress reset to "
            "remove the test progress and start over again."
            .hardcoded, textAlign: TextAlign.center),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text("eligibilityCheck".hardcoded), // questionnaire?
              onPressed: (!state.canTest) ? null : () {
                frameController.navigatePage("eligibilityCheck");
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text("interventionSelection".hardcoded),
              onPressed: (!state.canTest) ? null : () {
                frameController.navigatePage("interventionSelection");
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text("consent".hardcoded),
              onPressed: (!state.canTest) ? null : () {
                frameController.navigatePage("consent");
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text("dashboard".hardcoded),
              onPressed: (!state.canTest) ? null : () {
                frameController.navigatePage("dashboard");
              },
            ),
          ],
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: Text("Reset".hardcoded),
                onPressed: (!state.canTest) ? null : () {
                  frameController.sendCmd("reset");
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.open_in_new_sharp),
                label: Text("Open in new tab".hardcoded),
                onPressed: (!state.canTest) ? null : () {
                  frameController.openNewPage();
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.help),
                label: Text("How does this work?".hardcoded),
                onPressed: () => showHelp(ref),
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
                  children: [frameController.frameWidget, frameControls],
                );
              })
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
