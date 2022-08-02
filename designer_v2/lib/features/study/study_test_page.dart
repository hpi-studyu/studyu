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
        child: Row(
            children: [
              Expanded(
                flex: 3000,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 150),
                      const Text("This is the preview mode.\nPress reset to remove the test progress and start over again.\nLorem ipsum dolor sit amet",
                          textAlign: TextAlign.center
                      ),
                      const SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.restart_alt),
                              label: const Text("Reset"),
                              onPressed: () {
                                studyTestController.platformController.sendCmd("reset");
                              },
                            ),
                            TextButton.icon(
                                icon: const Icon(Icons.open_in_new_sharp),
                                label: const Text("Open in new tab"),
                                onPressed: () {
                                  studyTestController.platformController.openNewPage();
                                }
                            ),
                          ]
                      )
                    ]
                ),
              ),
              Expanded(
                  flex: 3000,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      studyTestController.platformController.scaffold,
                    ],
                  )
              ),
              Expanded(
                  flex: 3000,
                  child: Column(
                  )
              )
            ]
        )
    );
  }
}
