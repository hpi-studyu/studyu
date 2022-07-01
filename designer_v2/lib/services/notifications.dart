import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';

class Notifications {
  static final studyDeleted = NotificationMessage(
    message: "Study was deleted from your account".hardcoded,
    icon: Icons.delete
  );
}

