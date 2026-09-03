import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

// todo move this either to study_test_fame_views or do something like PreviewWidget(
class FrameControlsWidget extends ConsumerWidget {
  const FrameControlsWidget({this.enabled = true, this.onRefresh, super.key});

  final VoidCallback? onRefresh;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.restart_alt),
          label: Text(tr.action_button_study_test_reset),
          onPressed: (!enabled) ? null : onRefresh,
        ),
      ],
    );
  }
}
