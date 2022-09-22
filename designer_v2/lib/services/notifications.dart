import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';

class Notifications {
  static final passwordReset = SnackbarIntent(
    message: tr.notification_password_reset_check_email,
  );
  static final passwordResetSuccess = SnackbarIntent(
    message: tr.notification_password_reset_success,
  );
  static final studyDeleted = SnackbarIntent(
    message: tr.notification_study_deleted,
  );
  static final inviteCodeDeleted = SnackbarIntent(
    message: tr.notification_code_deleted,
  );
  static final inviteCodeClipped = SnackbarIntent(
    message: tr.notification_code_clipboard,
  );
  static final studyDeleteConfirmation = AlertIntent(
    title: tr.dialog_study_delete_title,
    message: tr.dialog_study_delete_description,
    icon: Icons.delete_rounded,
    actions: [NotificationDefaultActions.cancel]
  );
}

class NotificationDefaultActions {
  static final cancel = NotificationAction(
    label: tr.dialog_cancel,
    onSelect: () => Future.value(),
  );
}
