import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_controllers.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

// todo move this either to study_test_fame_views or do something like PreviewWidget(
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
                  frameController.refresh(cmd: "reset");
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.open_in_new_sharp),
                label: Text("Open in new tab".hardcoded),
                onPressed: (!state.canTest) ? null : () {
                  frameController.openNewPage();
                },
              ),
            ]
    );
  }
}
