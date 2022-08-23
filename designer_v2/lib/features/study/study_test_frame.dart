import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_test_controls.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class PreviewFrame extends StudyPageWidget {
  final PlatformController? frameController_;
  final StudyTestControllerState? state_;
  final TestArgs testArgs;
  PreviewFrame(this.testArgs, { this.frameController_, this.state_, Key? key}) : super(testArgs.studyId, key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudyTestControllerState state = state_ ?? ref.watch(studyTestControllerProvider(studyId));
    final PlatformController frameController = frameController_ ?? ref.watch(studyTestPlatformControllerProvider(testArgs));
    final formViewModel = ref.watch(studyTestValidatorProvider(studyId));

    if (testArgs.routeArgs is InterventionFormRouteArgs ) {
      final extra = testArgs.routeArgs as InterventionFormRouteArgs;
      print("NAVIGATE TO INTERVENTION");
      frameController.navigate(page: 'intervention', extra: extra.interventionId);
    } else if (testArgs.routeArgs is MeasurementFormRouteArgs) {
      final extra = testArgs.routeArgs as MeasurementFormRouteArgs;
      print("NAVIGATE TO OBSERVATION");
      frameController.navigate(page: 'observation', extra: extra.measurementId);
    }

    frameController.listen();

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
                  children: [frameController.frameWidget, FrameControlsWidget(frameController, state)],
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
}
