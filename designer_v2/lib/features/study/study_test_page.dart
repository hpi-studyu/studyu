import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';

class StudyTestScreen extends ConsumerStatefulWidget {
  StudyTestScreen(this.studyId, {Key? key}) : super(key: key);

  final String studyId;

  @override
  ConsumerState<StudyTestScreen> createState() => _StudyTestScreen();
}

class _StudyTestScreen extends ConsumerState<StudyTestScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(StudyTestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final studyTestController =
        ref.read(studyTestControllerProvider(widget.studyId).notifier);

    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Attention: Subscribing to a preview study currently deletes your all previous study progress on this device, INCLUDING the StudyU App.\nOnly use the preview feature if you are fine with this. (Will be fixed in a later version)"),
            studyTestController.platformController.scaffold,
            IconButton(
                icon: const Icon(Icons.restart_alt),
                onPressed: () {
                    studyTestController.platformController.sendCmd("reset");
                }
            ),
            //const SizedBox(width: 1,),
            const Text("Reset progress")
          ],
        ));
  }
}
