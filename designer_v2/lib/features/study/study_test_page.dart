import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';


class StudyTestScreen extends ConsumerStatefulWidget {
  const StudyTestScreen(this.studyId, {Key? key}) : super(key: key);

  final String studyId;

  @override
  ConsumerState<StudyTestScreen> createState() => _StudyTestScreen();
}

class _StudyTestScreen extends ConsumerState<StudyTestScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO error handling Study?
    final study = ref.watch(studyControllerProvider(widget.studyId)).study.value;
    final studyTestController = ref.read(studyTestControllerProvider(study!).notifier);
    final controller = studyTestController.platformController;

    return Container(
        alignment: Alignment.center,
        child: Row(
            children: [
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 150),
                      Text(tr.this_preview_mode+ tr.press_reset,
                          textAlign: TextAlign.center
                      ),
                      const SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.restart_alt),
                              label: Text(tr.reset),
                              onPressed: () {
                                controller.sendCmd("reset");
                              },
                            ),
                            TextButton.icon(
                                icon: const Icon(Icons.open_in_new_sharp),
                                label: Text(tr.open_in_tab),
                                onPressed: () {
                                  controller.openNewPage();
                                }
                            ),
                          ]
                      )
                    ]
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    studyTestController.platformController.scaffold,
                  ],
                )
              ),
              Expanded(
                child: Column()
              )
            ]
        )
    );
  }
}
