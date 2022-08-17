import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';

class Notifications {
  static final studyDeleted = SnackbarIntent(
    message: "Study was deleted from your account".hardcoded,
  );
  static final inviteCodeDeleted = SnackbarIntent(
    message: "Access code deleted".hardcoded,
  );
  static final inviteCodeClipped = SnackbarIntent(
    message: "Access code copied".hardcoded,
  );
  static final studyDeleteConfirmation = AlertIntent(
    title: "Permanently delete?".hardcoded,
    message: "Are you sure you want to delete this study? You will "
          "permanently lose the study and all data that has been "
          "collected.".hardcoded,
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
    label: "Cancel".hardcoded,
    onSelect: () => Future.value(),
  );
}
