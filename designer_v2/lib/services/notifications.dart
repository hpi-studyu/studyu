import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';
import 'package:url_launcher/url_launcher.dart';

class Notifications {
  static final passwordReset = SnackbarIntent(
    message: "Check your email for a password reset link!".hardcoded,
  );
  static final passwordResetSuccess = SnackbarIntent(
    message: "Password was reset successfully".hardcoded,
  );
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
}

class NotificationDefaultActions {
  static final cancel = NotificationAction(
    label: "Cancel".hardcoded,
    onSelect: () => Future.value(),
  );
}
