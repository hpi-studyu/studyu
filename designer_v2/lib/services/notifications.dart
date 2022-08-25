import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

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
  static final welcomeTestMode = AlertIntent(
      title: "WIP WIP WIP Testing your Study".hardcoded,
      // todo use paragraph and better text formatting
      message: "This page allows you to experience your study like one of your study's partifipants, so that you can tailor the design to your needs and verify everything works correctly.\n\n\n"
          "Pro Tips\n\n"
          "- Use the menu in the top-left to quickly preview and jump to different parts of your study (e.g. surveys)\n"
          "- To get a fresh experience, you can reset all data and enroll as a new test user\n"
          "- Yuu can also download (LINK) the StudyU app on your phone for testing\n"
          "\n\n\n"
          "Please note \n\n"
          "- All test users and their data will be reset one you launch the study\n"
          "RAUS - When you make changes to your study design, a new test user is created automatically\n".hardcoded,
      icon: Icons.star,
  );
}

class NotificationDefaultActions {
  static final cancel = NotificationAction(
    label: tr.cancel,
    onSelect: () => Future.value(),
  );
}
