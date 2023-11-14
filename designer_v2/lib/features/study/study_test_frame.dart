import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_controls.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

class PreviewFrame extends ConsumerStatefulWidget {
  const PreviewFrame(
    this.studyId, {
    this.routeArgs,
    this.route,
    super.key,
  }) : assert(
            (routeArgs != null && route == null) ||
                (routeArgs == null && route != null) ||
                (routeArgs == null && route == null),
            "Must not specify both routeArgs and route");

  final StudyID studyId;
  final StudyFormRouteArgs? routeArgs;
  final String? route;

  @override
  ConsumerState<PreviewFrame> createState() => _PreviewFrameState();
}

class _PreviewFrameState extends ConsumerState<PreviewFrame> {
  PlatformController? frameController;

  @override
  void initState() {
    super.initState();
    runAsync(() => _subscribeStudyChanges());
  }

  @override
  void didUpdateWidget(PreviewFrame oldWidget) {
    if (mounted) runAsync(() => _subscribeStudyChanges());
    super.didUpdateWidget(oldWidget);
  }

  _subscribeStudyChanges() {
    final formViewModelCurrent = ref.read(studyFormViewModelProvider(widget.studyId));

    formViewModelCurrent.form.valueChanges.listen((event) {
      if (frameController != null) {
        final formJson = jsonEncode(formViewModelCurrent.buildFormData().toJson());
        frameController!.send(formJson);
      }
    });
  }

  _updatePreviewRoute() {
    if (widget.route != null) {
      frameController!.generateUrl(route: widget.route);
    } else {
      String route = 'default';

      if (widget.routeArgs is InterventionFormRouteArgs) {
        route = 'intervention';
        frameController!
            .generateUrl(route: route, extra: (widget.routeArgs as InterventionFormRouteArgs).interventionId);
      } else if (widget.routeArgs is MeasurementFormRouteArgs) {
        route = 'observation';
        frameController!.generateUrl(route: route, extra: (widget.routeArgs as MeasurementFormRouteArgs).measurementId);
      } else {
        frameController!.generateUrl();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyTestControllerProvider(widget.studyId));
    final formViewModel = ref.watch(studyTestValidatorProvider(widget.studyId));

    // Rebuild iframe component & url
    frameController = ref.read(studyTestPlatformControllerProvider(widget.studyId));
    _updatePreviewRoute();
    frameController!.activate();
    frameController!.listen();

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < PhoneContainer.defaultWidth) {
        // Not enough space to render app preview
        return Container();
      }

      return Stack(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ReactiveForm(
              formGroup: formViewModel.form,
              child: ReactiveFormConsumer(
                builder: (context, form, child) {
                  if (formViewModel.form.hasErrors) {
                    return const DisabledFrame();
                  }
                  return Column(
                    children: [
                      frameController!.frameWidget,
                      const SizedBox(height: 8.0),
                      FrameControlsWidget(
                        onRefresh: () => frameController!.refresh(cmd: "reset"),
                        onOpenNewTab: () => frameController!.openNewPage(),
                        enabled: state.canTest,
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ]);
    });
  }
}
