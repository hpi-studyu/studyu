import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class InterventionPreview extends ConsumerWidget {
  const InterventionPreview({
    required this.routeArgs,
    Key? key
  }) : super(key: key);

  final InterventionFormRouteArgs routeArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
        child: Column(
            children: [
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
            ]
        )
    );
  }
}
