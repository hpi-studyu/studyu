import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/router.dart';

class StudyRecruitScreen extends StatelessWidget {
  const StudyRecruitScreen(this.studyId, {Key? key}) : super(key: key);

  final String studyId;

  @override
  Widget build(BuildContext context) {
    print("StudyRecruitScreen.build");
    return Container(
      alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Recruit participants: $studyId"),
            TextButton(
                onPressed: () => context.goNamed(RouterPage.studyEditor.id, params: {"studyId": studyId}),
                child: Text("Go to editor")
            ),
          ],
        )
    );
  }
}
