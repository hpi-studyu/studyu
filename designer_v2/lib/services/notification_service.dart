import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/subjects.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';


abstract class INotificationService {
  void showMessage(String notificationText, {List<NotificationAction>? actions});
  void show(NotificationIntent notification, {List<NotificationAction>? actions});
  Stream<NotificationIntent> watchNotifications();
  // - Lifecycle
  void dispose();
}

/// Notification center that is responsible for showing [NotificationIntent]s
/// across the app via snackbars or alerts.
///
/// Enables notifications to be decoupled from UI widgets so that
/// they can be dispatched by controllers / blocs & tested independently
class NotificationService implements INotificationService {
  /// A stream controller that exposes a stream of [Notifications]s that
  /// are consumed & dispatched by a [NotificationDispatcher] widget
  final BehaviorSubject<NotificationIntent> _streamController = BehaviorSubject();

  @override
  Stream<NotificationIntent> watchNotifications() => _streamController.stream;

  @override
  void showMessage(String message, {List<NotificationAction>? actions}) {
    show(SnackbarIntent(message: message), actions: actions);
  }

  @override
  void show(NotificationIntent notification,
      {List<NotificationAction>? actions}) {
    // Register any additional actions passed as callbacks by the calling code
    if (actions != null) {
      for (final action in actions) {
        notification.register(action);
      }
    }
    _streamController.add(notification);
  }

  @override
  void dispose() {
    _streamController.close();
  }
}

final notificationServiceProvider = Provider<INotificationService>((ref) {
  final notificationService = NotificationService();
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    notificationService.dispose();
  });
  return notificationService;
});
