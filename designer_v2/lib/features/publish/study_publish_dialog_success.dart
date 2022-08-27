import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class PublishSuccessDialog extends StudyPageWidget {
  const PublishSuccessDialog(super.studyId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(studyControllerProvider(studyId).notifier);
    final theme = Theme.of(context);

    return StandardDialog(
      body: Column(
        children: [
          const SizedBox(height: 24.0),
          EmptyBody(
            leading: Text("\u{1f389}",
                style: theme.textTheme.headline1?.copyWith(
                  fontSize: (theme.textTheme.headline1?.fontSize ?? 48.0) * 1.5,
                )),
            title: "Your study is live!".hardcoded,
            description:
                "Next, you can start inviting and enrolling your participants in the StudyU app."
                    .hardcoded,
          ),
          const SizedBox(height: 12.0),
        ],
      ),
      actionButtons: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PrimaryButton(
              text: "Add participants".hardcoded,
              onPressed: () => Navigator.maybePop(context)
                  .whenComplete(() => controller.onAddParticipants()),
            ),
            const SizedBox(height: 8.0),
            Opacity(
              opacity: 0.75,
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Text("Skip for now".hardcoded),
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
