import 'package:flutter/widgets.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';

enum NotificationType { snackbar, alert, custom }

/// Base class for notifications that are dispatched via [NotificationService]
/// to inform the user & capture their attention.
///
/// The currently supported notification types are:
///   [SnackbarIntent] - renders the notification as a snackbar
///   [AlertIntent] - renders the notification as an alert dialog
abstract class NotificationIntent {
  NotificationIntent({this.message, this.customContent, this.icon, this.actions, required this.type}) {
    if (message == null && customContent == null) throw Exception("Invalid AlertIntent");
  }

  final String? message;
  final Widget? customContent;
  final IconData? icon;
  List<NotificationAction>? actions;
  final NotificationType type;

  void register(NotificationAction action) {
    actions ??= [];
    // upsert action by its label
    final existingIdx = actions!.map((action) => action.label).toList().indexOf(action.label);
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

  NotificationAction({required this.label, required this.onSelect, this.isDestructive = false});
}

/// Encapsulates a call to [showSnackbar]
class SnackbarIntent extends NotificationIntent {
  SnackbarIntent({
    required String super.message,
    super.icon,
    super.actions,
    this.duration,
  }) : super(type: NotificationType.snackbar);

  final int? duration;
}

/// Encapsulates a call to [showDialog] using an alert-style widget
class AlertIntent extends NotificationIntent {
  AlertIntent({
    required this.title,
    super.message,
    super.customContent,
    super.icon,
    super.actions,
    this.dismissOnAction = true,
  }) : super(type: NotificationType.alert);

  final String title;
  final bool dismissOnAction;

  get isDestructive => (actions == null) ? false : actions!.any((action) => action.isDestructive);
}
