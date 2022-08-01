import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/subjects.dart';


/// Encapsulates a call to [showDialog] or [showSnackbar]
class NotificationMessage extends Equatable {
  const NotificationMessage({
    required this.message,
    this.icon,
    this.duration,
    this.actions = const [],
  });

  final String message;
  final IconData? icon;
  final int? duration;
  final List<NotificationAction> actions;

  @override
  List<Object?> get props => [message, duration, actions];
}

class NotificationAction {
  final String label;
  final Function onExecute;

  NotificationAction(this.label, this.onExecute);
}

abstract class INotificationService {
  void showMessage(String notificationText);
  void show(NotificationMessage notification);
  Stream<NotificationMessage> watchNotifications();
  // - Lifecycle
  void dispose();
}

/// Notification center that is responsible for showing [NotificationMessage]s
/// across the app via snackbars or alerts.
///
/// Enables notifications to be decoupled from UI widgets so that
/// they can be dispatched by controllers / blocs & tested independently
class NotificationService implements INotificationService {
  /// A stream controller that exposes a stream of [Notifications]s that
  /// are consumed & dispatched by a [NotificationDispatcher] widget
  final BehaviorSubject<NotificationMessage> _streamController = BehaviorSubject();

  @override
  Stream<NotificationMessage> watchNotifications() => _streamController.stream;

  @override
  void showMessage(String message) {
    show(NotificationMessage(message: message));
  }

  @override
  void show(NotificationMessage notification) {
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
