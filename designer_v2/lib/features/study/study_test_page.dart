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
    bool missingRequirements = studyTestController.missingRequirements.isNotEmpty;

    return ListView (
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        if (missingRequirements) ... [
          SizedBox(
            width: 10,
            height: 50,
            child: OverflowBox(
              minWidth: 0,
              minHeight: 0.0,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE99C),
                  border: Border.all(width: 3, color: const Color(0xFFFFC808)),
                ),
                child: Row(
                    children: [
                      const SizedBox(width: 50),
                      const Icon(Icons.info),
                      const SizedBox(width: 10),
                      Text(
                        "This study cannot be previewed, unless the following fields are set: ${studyTestController.missingRequirements.keys}".hardcoded,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(width: 50),
                    ]
                ),
              ),
            ),
          ),
          const SizedBox(height: 20,),
        ],
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              controller.scaffold,
              const SizedBox(height: 20),
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
                        missingRequirements ? null : controller.sendCmd("reset");
                      },
                    ),
                    TextButton.icon(
                        icon: const Icon(Icons.open_in_new_sharp),
                        label: Text("Open in new tab".hardcoded),
                        onPressed: () {
                          missingRequirements ? null : controller.openNewPage();
                        }
                    ),
                  ]
              ),
            ],
          ),
        ]
    );
  }
}
