import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/features/study/study_test_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class StudyTestScreen extends StudyPageWidget {
  const StudyTestScreen(studyId, {Key? key})
      : super(studyId, key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO error handling Study?
    final study = ref.watch(studyControllerProvider(studyId)).study.value;
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
                      Text("This is the preview mode.\nPress reset to "
                          "remove the test progress and start over again.".hardcoded,
                          textAlign: TextAlign.center
                      ),
                      const SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.restart_alt),
                              label: Text("Reset".hardcoded),
                              onPressed: () {
                                controller.sendCmd("reset");
                              },
                            ),
                            TextButton.icon(
                                icon: const Icon(Icons.open_in_new_sharp),
                                label: Text("Open in new tab".hardcoded),
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
