import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';

class StudyPreviewLayout extends ConsumerWidget {
  const StudyPreviewLayout({required this.routeArgs, super.key});

  final StudyFormRouteArgs routeArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: ThemeConfig.sidesheetBackgroundColor(Theme.of(context)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Expanded(
                  child: PreviewFrame(routeArgs.studyId, routeArgs: routeArgs),
                ),
              ],
            ),
          ),
          previewBanner(ref, routeArgs.studyId) ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
