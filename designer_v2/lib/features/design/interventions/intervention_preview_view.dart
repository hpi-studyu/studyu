import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class InterventionPreview extends ConsumerWidget {
  const InterventionPreview({required this.routeArgs, super.key});

  final InterventionFormRouteArgs routeArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
        child: Column(children: [
          Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 50),
                  PreviewFrame(routeArgs.studyId, routeArgs: routeArgs),
                ],
              ),
              previewBanner(ref, routeArgs.studyId) ?? const SizedBox.shrink(),
            ],
          ),
        ]));
  }
}
