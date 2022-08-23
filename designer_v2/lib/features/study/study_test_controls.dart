import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
/*
class FrameControls {

  Widget previewControls(WidgetRef ref, StudyTestControllerState state, PlatformController frameController) {

  }
}*/

// todo move this either to stuy_test_fame_views or do something like PreviewWidget(
// routeArgs,
// frameControls: (PlatformController frameController, WidgetRef ref) => Column(...);
// )
class FrameControlsWidget extends ConsumerWidget {
  final PlatformController frameController;
  final StudyTestControllerState state;

  const FrameControlsWidget(this.frameController, this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
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
              /*TextButton.icon(
                icon: const Icon(Icons.help),
                label: Text("How does this work?".hardcoded),
                onPressed: () => showHelp(ref),
              ),*/
            ]);
  }
}

/*class FrameControlsWidget extends ConsumerStatefulWidget {
  final String studyId;
  final Widget controls;

  const FrameControlsWidget(this.studyId, this.controls, {Key? key}) : super(key: key);

  @override
  _FrameControlsState createState() => _FrameControlsState();
}

class _FrameControlsState extends ConsumerState<FrameControlsWidget> {

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}*/