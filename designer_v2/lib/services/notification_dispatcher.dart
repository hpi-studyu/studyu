import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notification_types.dart';

/// A wrapper widgets that is subscribed to the [NotificationService] and
/// automatically dispatches its [NotificationIntent]s to show a Snackbar.
class NotificationDispatcher extends ConsumerStatefulWidget {
  const NotificationDispatcher(
      {required this.child,
      this.scaffoldMessengerKey,
      this.navigatorKey,
      this.snackbarWidth,
      this.snackbarInnerPadding = 16.0,
      this.snackbarBehavior = SnackBarBehavior.fixed,
      this.snackbarDefaultDuration = 2500,
      super.key});

  /// Pass-through widget that is rendered as is
  final Widget? child;

  /// The global key used for looking up the [Scaffold] reference
  /// If not specified explicitly, falls back `ScaffoldMessenger.of(context)`
  /// to look up the closest instance of [ScaffoldMessengerState]
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// The global key used for looking up the [Navigator] reference
  /// If not specified explicitly, falls back `Navigator.of(context)`
  /// to look up the closest instance of [NavigatorState]
  final GlobalKey<NavigatorState>? navigatorKey;

  final double snackbarInnerPadding;
  final double? snackbarWidth;
  final SnackBarBehavior snackbarBehavior;
  final int snackbarDefaultDuration;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotificationDispatcherState();
}

class _NotificationDispatcherState extends ConsumerState<NotificationDispatcher> {
  /// Subscription to a stream of [NotificationIntent]s to be dispatched
  late final StreamSubscription<NotificationIntent> _subscription;

  bool _isValidated = false;

  @override
  void initState() {
    super.initState();
    _subscription = ref.read(notificationServiceProvider).watchNotifications().listen(_handleNotification);
  }

  ScaffoldMessengerState _getMessengerState() {
    final ScaffoldMessengerState messengerState;
    try {
      if (widget.scaffoldMessengerKey != null) {
        messengerState = widget.scaffoldMessengerKey!.currentState!;
      } else {
        messengerState = ScaffoldMessenger.of(context);
      }
    } catch (_) {
      throw Exception("NotificationDispatcher could not obtain reference to "
          "ScaffoldMessengerState. Make sure the widget is placed below "
          "a Scaffold or MaterialApp in the widget tree, or provide a reference "
          "via the scaffoldMessengerKey global key.");
    }
    return messengerState;
  }

  NavigatorState? _getNavigatorState() {
    final NavigatorState? navigatorState;
    try {
      if (widget.navigatorKey != null) {
        // [NavigatorState] may be null during initial build / validation when
        // navigator is not initialized yet. As long as there is a valid key
        // we should be good!
        navigatorState = widget.navigatorKey!.currentState;
      } else {
        navigatorState = Navigator.of(context);
      }
    } catch (_) {
      throw Exception("NotificationDispatcher context could not obtain reference to "
          "NavigatorState. Make sure the NotificationDispatcher is placed below "
          "a Navigator in the widget tree, or provide a reference via the "
          "navigatorKey global key.");
    }
    return navigatorState;
  }

  void _handleNotification(NotificationIntent notification) {
    switch (notification.type) {
      case NotificationType.snackbar:
        final messengerState = _getMessengerState();
        messengerState.showSnackBar(_buildSnackbar(notification as SnackbarIntent, messengerState));
        break;
      case NotificationType.alert:
        final navigatorState = _getNavigatorState()!;
        showDialog(
            context: navigatorState.context,
            builder: (BuildContext context) => _buildAlertDialog(notification as AlertIntent, navigatorState));
        break;
      default:
        throw UnimplementedError("Failed to handle NotificationIntent of unexpected type.");
    }
  }

  AlertDialog _buildAlertDialog(AlertIntent notification, NavigatorState navigatorState) {
    final textTheme = Theme.of(context).textTheme;

    final List<Widget> actions = [];
    if (notification.actions != null) {
      for (final action in notification.actions!) {
        actions.add(TextButton(
          onPressed: () {
            if (notification.dismissOnAction) {
              // always pop & don't wait for [action.onSelect]
              navigatorState.pop();
            }
            action.onSelect();
          },
          child: Text(action.label,
              style: (action.isDestructive)
                  ? textTheme.labelLarge!.copyWith(color: Colors.redAccent)
                  : textTheme.labelLarge!),
        ));
      }
    }

    return AlertDialog(
      title: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(notification.icon),
        Text("️ ${notification.title}", style: textTheme.displaySmall),
      ]),
      content: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 300,
            maxWidth: MediaQuery.of(context).size.width * 0.33,
          ),
          child: Row(children: [
            Flexible(
              child: notificationContent(notification.message, notification.customContent),
            ),
          ])),
      actions: actions,
    );
  }

  Widget notificationContent(String? message, Widget? customContent) {
    if (customContent != null) {
      return customContent;
    } else {
      return Text(message!);
    }
  }

  SnackBar _buildSnackbar(SnackbarIntent notification, ScaffoldMessengerState messengerState) {
    final theme = Theme.of(context);

    return SnackBar(
      width: (widget.snackbarBehavior == SnackBarBehavior.floating) ? widget.snackbarWidth : null,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (notification.icon != null)
              ? Padding(
                  padding: EdgeInsets.all(0.5 * widget.snackbarInnerPadding),
                  child: Icon(notification.icon,
                      size: 2 / 3 * widget.snackbarInnerPadding, color: theme.snackBarTheme.actionTextColor),
                )
              : const SizedBox.shrink(),
          Text(notification.message!, style: theme.textTheme.titleMedium!.copyWith(color: theme.colorScheme.onPrimary))
        ],
      ),
      duration: Duration(milliseconds: notification.duration ?? widget.snackbarDefaultDuration),
      padding: EdgeInsets.fromLTRB(2.5 * widget.snackbarInnerPadding, widget.snackbarInnerPadding,
          1.5 * widget.snackbarInnerPadding, widget.snackbarInnerPadding),
      behavior: widget.snackbarBehavior,
      action: SnackBarAction(
        label: "X".hardcoded,
        onPressed: () {
          messengerState.hideCurrentSnackBar();
        },
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Try to obtain a [ScaffoldMessengerState] as an initial check that this
    // widget is placed correctly in the widget tree
    if (!_isValidated) {
      _getMessengerState();
      _getNavigatorState();
      // Remember validation for future builds avoiding setState during build
      Future.delayed(const Duration(milliseconds: 0), () => setState(() => _isValidated = true));
    }
    return widget.child ?? Container();
  }
}
