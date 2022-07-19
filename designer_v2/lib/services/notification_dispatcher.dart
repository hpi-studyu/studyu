import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';


/// A wrapper widgets that is subscribed to the [NotificationService] and
/// automatically dispatches its [NotificationMessage]s to show a Snackbar.
class NotificationDispatcher extends ConsumerStatefulWidget {
  const NotificationDispatcher({
    required this.child,
    this.scaffoldMessengerKey,
    this.snackbarWidth,
    this.snackbarInnerPadding = 36.0,
    this.snackbarBehavior = SnackBarBehavior.fixed,
    this.snackbarDefaultDuration = 2500,
    Key? key
  }) : super(key: key);

  /// Pass-through widget that is rendered as is
  final Widget? child;

  /// The global key used for looking up the scaffold reference
  /// If not specified explicitly, falls back `ScaffoldMessenger.of(context)`
  /// to look up the closest instance of [ScaffoldMessengerState]
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  final double snackbarInnerPadding;
  final double? snackbarWidth;
  final SnackBarBehavior snackbarBehavior;
  final int snackbarDefaultDuration;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotificationDispatcherState();
}

class _NotificationDispatcherState extends ConsumerState<NotificationDispatcher> {
  /// Subscription to a stream of [NotificationMessage]s to be dispatched
  late final StreamSubscription<NotificationMessage> _subscription;

  bool _isValidated = false;

  @override
  void initState() {
    super.initState();
    _subscription = ref.read(notificationServiceProvider)
        .watchNotifications()
        .listen(_handleNotification);
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
      throw Exception(
          "NotificationDispatcher could not obtain reference to "
          "ScaffoldMessengerState. Make sure the widget is placed below "
          "a Scaffold or MaterialApp in the widget tree, or provide a reference "
          "via the scaffoldMessengerKey global key."
      );
    }

    return messengerState;
  }

  void _handleNotification(NotificationMessage notification) {
    final messengerState = _getMessengerState();
    messengerState.showSnackBar(
        _buildSnackbar(notification, messengerState));
  }

  SnackBar _buildSnackbar(NotificationMessage notification,
      ScaffoldMessengerState messengerState) {
    final theme = Theme.of(context);

    return SnackBar(
      width: (widget.snackbarBehavior == SnackBarBehavior.floating)
          ? widget.snackbarWidth : null,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (notification.icon != null) ?
            Padding(
              padding: EdgeInsets.all(0.5*widget.snackbarInnerPadding),
              child: Icon(notification.icon,
                  size: 2/3*widget.snackbarInnerPadding,
                  color: theme.snackBarTheme.actionTextColor),
            ) : const SizedBox(),
          Text(notification.message, style: theme.textTheme.titleMedium!
              .copyWith(color: theme.colorScheme.onPrimary))
        ],
      ),
      duration: Duration(
          milliseconds: notification.duration ?? widget.snackbarDefaultDuration),
      padding: EdgeInsets.fromLTRB(
          2.5*widget.snackbarInnerPadding, widget.snackbarInnerPadding,
          1.5*widget.snackbarInnerPadding, widget.snackbarInnerPadding),
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
      // Remember validation for future builds avoiding setState during build
      Future.delayed(const Duration(milliseconds: 0), () =>
          setState(() => _isValidated = true));
    }
    return widget.child ?? Container();
  }
}
