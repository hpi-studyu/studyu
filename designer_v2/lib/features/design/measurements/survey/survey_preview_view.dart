import 'package:flutter/material.dart';
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
              child: const Center(
                // TODO: implement SurveyPreview widget
                child: Text("[TODO SurveyPreview]")
              ),
            )
        )
      ],
    );
  }
}
