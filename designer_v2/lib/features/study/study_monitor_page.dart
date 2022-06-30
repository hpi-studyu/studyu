import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/routing/router.dart';

class StudyMonitorScreen extends StatelessWidget {
  const StudyMonitorScreen(this.studyId, {Key? key}) : super(key: key);

  final String studyId;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Monitor study: $studyId"),
          TextButton(
              onPressed: () => context.goNamed(RouterPage.studyAnalysis.id, params: {"studyId": studyId}),
              child: Text("Go to analyze")
          ),
        ],
      )
    );
  }
}
