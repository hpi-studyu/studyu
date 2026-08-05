import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_flutter_common/src/utils/connection_status_platform.dart';

enum AppConnectionStatus { healthy, deviceOffline, backendUnavailable }

class AppConnectionStatusController extends ChangeNotifier {
  AppConnectionStatusController._();

  static final AppConnectionStatusController instance =
      AppConnectionStatusController._();

  AppConnectionStatus _status = AppConnectionStatus.healthy;

  AppConnectionStatus get status => _status;

  void setStatus(AppConnectionStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    if (_status == AppConnectionStatus.healthy) return;
    _status = AppConnectionStatus.healthy;
    notifyListeners();
  }
}

AppConnectionStatusController get appConnectionStatusController =>
    AppConnectionStatusController.instance;

AppConnectionStatus? connectionStatusFromError(
  Object error, {
  AppConnectionStatus fallbackStatus = AppConnectionStatus.backendUnavailable,
}) {
  final onlineState = isDeviceOnline();

  if (error is SocketException) {
    final message = error.toString().toLowerCase();
    if (message.contains('connection refused')) {
      return AppConnectionStatus.backendUnavailable;
    }
    return _statusForTransportFailure(onlineState, fallbackStatus);
  }
  if (error is TimeoutException) {
    return _statusForTransportFailure(onlineState, fallbackStatus);
  }

  final message = error.toString().toLowerCase();
  if (message.contains('invalid_credentials') ||
      message.contains('pgrst116') ||
      message.contains('pgrst301')) {
    return null;
  }
  if (message.contains('network is unreachable')) {
    return AppConnectionStatus.deviceOffline;
  }
  if (message.contains('connection refused')) {
    return AppConnectionStatus.backendUnavailable;
  }
  if (message.contains('failed host lookup') ||
      message.contains('no address associated') ||
      message.contains('socketexception')) {
    return _statusForTransportFailure(onlineState, fallbackStatus);
  }
  if (message.contains('connection timeout') ||
      message.contains('failed to fetch') ||
      message.contains('xmlhttprequest error') ||
      message.contains('clientexception') ||
      message.contains('timed out')) {
    return _statusForTransportFailure(onlineState, fallbackStatus);
  }

  return null;
}

AppConnectionStatus _statusForTransportFailure(
  bool? onlineState,
  AppConnectionStatus fallbackStatus,
) {
  if (onlineState == false) {
    return AppConnectionStatus.deviceOffline;
  }
  return fallbackStatus;
}
