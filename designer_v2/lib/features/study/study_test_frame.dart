import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_test_controls.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

// todo make this immutable
class PreviewFrame extends ConsumerWidget {
  late PlatformController? frameController;
  late StudyTestControllerState? state;
  final StudyID studyId;
  final StudyFormRouteArgs? routeArgs;
  PreviewFrame(this.studyId, {this.routeArgs, this.frameController, this.state, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    state ??= ref.watch(studyTestControllerProvider(studyId));
    frameController ??= ref.watch(studyTestPlatformControllerProvider(studyId));
    final formViewModel = ref.watch(studyTestValidatorProvider(studyId));
    String formType = 'default';

    if (routeArgs is InterventionFormRouteArgs ) {
      formType = 'intervention';
      frameController!.navigate(page: formType, extra: (routeArgs as InterventionFormRouteArgs).interventionId);
    } else if (routeArgs is MeasurementFormRouteArgs) {
      formType = 'observation';
      frameController!.navigate(page: formType, extra: (routeArgs as MeasurementFormRouteArgs).measurementId);
    }

    final formViewModelCurrent = ref.read(studyFormViewModelProvider(studyId));
    formViewModelCurrent.form.valueChanges.listen((event) {
      final formJson = jsonEncode(formViewModelCurrent.buildFormData().toJson());
      //frameController!.navigate(page: formType, data: formJson);
      frameController!.send(formJson);
    });

    frameController!.listen();

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
                  children: [frameController!.frameWidget, FrameControlsWidget(frameController!, state!)],
                );
              })
          ),
        ]
    );
  }
}
