import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:url_launcher/url_launcher.dart';

class Notifications {
  static final studyDeleted = SnackbarIntent(
    message: tr.study_deleted,
  );
  static final inviteCodeDeleted = SnackbarIntent(
    message: tr.access_code_deleted,
  );
  static final inviteCodeClipped = SnackbarIntent(
    message: tr.access_code_copied,
  );
  static final studyDeleteConfirmation = AlertIntent(
    title: tr.permanently_delete,
    message: tr.delete_study_question,
    icon: Icons.delete_rounded,
    actions: [NotificationDefaultActions.cancel]
  );

  static welcomeTestMode(BuildContext context) {
    final theme = Theme.of(context);
    return AlertIntent(
      title: "Testing your Study".hardcoded,
      customContent:
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextParagraph(text: "This page allows you to experience your study like one of your study's participants, so that you can tailor the design to your needs and verify everything works correctly.\n"),
          Align(alignment: Alignment.centerLeft, child: Text("\u{2b50} Pro Tips\n", style: theme.textTheme.headline5)),
          Align(alignment: Alignment.centerLeft, child: TextParagraph(span: [
            const TextSpan(text: "• Use the menu in the top-left to quickly preview and jump to different parts of your study (e.g. surveys)\n"
            "• To get a fresh experience, you can reset all data and enroll as a new test user\n"
            "• You can also "),
            TextSpan(
              text: 'download the StudyU app',
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(Uri.parse('https://github.com/hpi-studyu/studyu#app-stores')),
            ),
            const TextSpan(text: " on your phone for testing\n"),
          ])),
          Align(alignment: Alignment.centerLeft, child: Text("\u{26a0} Please note\n", style: theme.textTheme.headline5)),
          Align(alignment: Alignment.centerLeft, child: TextParagraph(text: "• All test users and their data will be reset one you launch the study\n")),
        ],
      ),
      icon: Icons.accessibility,
    );
  }
}

class NotificationDefaultActions {
  static final cancel = NotificationAction(
    label: tr.cancel,
    onSelect: () => Future.value(),
  );
}
