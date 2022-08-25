import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/study/study_test_page.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class SurveyPreview extends StatelessWidget {
  const SurveyPreview({
    required this.routeArgs,
    Key? key
  }) : super(key: key);

  final MeasurementFormRouteArgs routeArgs;

  @override
  Widget build(BuildContext context) {
    // TODO: provide SurveyPreviewController based on routeArgs
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
              child: Column( children: [ const SizedBox(height: 50), StudyTestScreen(routeArgs.studyId) ],),
            ),
        )
      ],
    );
  }
}
