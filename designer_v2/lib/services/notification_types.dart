import 'package:flutter/widgets.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';

enum NotificationType {
  snackbar, alert, custom
}

/// Base class for notifications that are dispatched via [NotificationService]
/// to inform the user & capture their attention.
///
/// The currently supported notification types are:
///   [SnackbarIntent] - renders the notification as a snackbar
///   [AlertIntent] - renders the notification as an alert dialog
abstract class NotificationIntent {
  NotificationIntent({
    required this.message,
    this.icon,
    this.actions,
    required this.type
  });

  final String message;
  final IconData? icon;
  List<NotificationAction>? actions;
  final NotificationType type;

  void register(NotificationAction action) {
    actions ??= [];
    // upsert action by its label
    final existingIdx = actions!.map((action) => action.label)
        .toList().indexOf(action.label);
    if (existingIdx != -1) {
      actions![existingIdx] = action;
    } else {
      actions!.add(action);
    }
  }
}

typedef FutureActionHandler = Future<void> Function();

class NotificationAction {
  final String label;
  final FutureActionHandler onSelect;
  final bool isDestructive;

  NotificationAction({
    required this.label,
    required this.onSelect,
    this.isDestructive = false
  });
}

/// Encapsulates a call to [showSnackbar]
class SnackbarIntent extends NotificationIntent {
  SnackbarIntent({
    required String message,
    IconData? icon,
    List<NotificationAction>? actions,
    this.duration,
  }) : super(
      message: message,
      icon: icon,
      actions: actions,
      type: NotificationType.snackbar
  );

  final int? duration;
}

/// Encapsulates a call to [showDialog] using an alert-style widget
class AlertIntent extends NotificationIntent {
  static NotificationAction cancelAction = NotificationAction(
      label: "Cancel".hardcoded,
      onSelect: () => Future.value(),
  );

  AlertIntent({
    required String message,
    required this.title,
    IconData? icon,
    List<NotificationAction>? actions,
    this.dismissOnAction = true,
  }) : super(
      message: message,
      icon: icon,
      actions: actions,
      type: NotificationType.alert
  );

  final String title;
  final bool dismissOnAction;

  get isDestructive => (actions == null) ? false
      : actions!.any((action) => action.isDestructive);
}
