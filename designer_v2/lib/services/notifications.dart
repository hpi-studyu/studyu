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
}

class NotificationDefaultActions {
  static final cancel = NotificationAction(
    label: tr.cancel,
    onSelect: () => Future.value(),
  );
}
