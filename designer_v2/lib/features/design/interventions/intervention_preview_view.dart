import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class InterventionPreview extends StatelessWidget {
  const InterventionPreview({
    required this.routeArgs,
    Key? key
  }) : super(key: key);

  final InterventionFormRouteArgs routeArgs;

  // todo implement a banner here to show validation errors

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
        child: Column(
            children: [
              const SizedBox(height: 50),
              PreviewFrame(routeArgs.studyId, routeArgs: routeArgs),
            ]
        )
    );
  }
}
