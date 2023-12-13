import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class PublishSuccessDialog extends StudyPageWidget {
  const PublishSuccessDialog(super.studyCreationArgs, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(studyControllerProvider(studyCreationArgs).notifier);
    final theme = Theme.of(context);

    return StandardDialog(
      body: Column(
        children: [
          const SizedBox(height: 24.0),
          EmptyBody(
              leading: Text("\u{1f389}".hardcoded,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: (theme.textTheme.displayLarge?.fontSize ?? 48.0) * 1.5,
                  )),
              title: controller.studyType == StudyType.template
                  ? tr.template_launch_success_title
                  : tr.study_launch_success_title,
              description: controller.studyType == StudyType.template
                  ? tr.template_launch_success_description
                  : tr.study_launch_success_description),
          const SizedBox(height: 8.0),
        ],
      ),
      actionButtons: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PrimaryButton(
              text: controller.studyType == StudyType.template
                  ? tr.action_button_post_launch_followup_template
                  : tr.action_button_post_launch_followup,
              onPressed: () => Navigator.maybePop(context).whenComplete(() => controller.studyType == StudyType.template
                  ? controller.onCreateNewSubstudy()
                  : controller.onAddParticipants()),
            ),
            const SizedBox(height: 8.0),
            Opacity(
              opacity: 0.75,
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Text(tr.action_button_post_launch_followup_skip),
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
            )
          ],
        ))
      ],
      maxWidth: 450,
    );
  }
}
