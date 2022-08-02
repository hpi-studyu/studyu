import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';

class StudyTestScreen extends ConsumerStatefulWidget {
  const StudyTestScreen(this.studyId, {Key? key}) : super(key: key);

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
    final study = ref.watch(studyControllerProvider(widget.studyId)).study.value;

    // todo error handling Study?
    final studyTestController = ref.read(studyTestControllerProvider(study!).notifier);

    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            studyTestController.platformController.scaffold,
            IconButton(
                icon: const Icon(Icons.restart_alt),
                onPressed: () {
                    studyTestController.platformController.sendCmd("reset");
                }
            ),
            //const SizedBox(width: 1,),
            const Text("Reset preview")
          ],
        ));
  }
}
