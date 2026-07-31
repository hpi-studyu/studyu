import 'dart:async';
import 'dart:convert';

import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import "package:universal_html/html.dart" as html;

typedef PreviewNavigationHandler = Future<void> Function(String? route);

class IFrameHelper {
  // The listener must outlive LoadingScreen so loaded preview routes keep
  // receiving live study updates from the Designer.
  static StreamSubscription<html.MessageEvent>? _messageSubscription;

  String? _designerOrigin() {
    final uri = Uri.tryParse(env.designerUrl ?? '');
    return uri == null || !uri.hasScheme || uri.host.isEmpty
        ? null
        : uri.origin;
  }

  html.WindowBase? _parentWindow() {
    try {
      return html.window.parent;
    } catch (_) {
      return null;
    }
  }

  bool _isExpectedMessage(
    html.MessageEvent event,
    html.WindowBase parent,
    String designerOrigin,
  ) => event.origin == designerOrigin && event.source == parent;

  Future<String?> requestPreviewSession() async {
    final parent = _parentWindow();
    final designerOrigin = _designerOrigin();
    if (parent == null || designerOrigin == null) return null;

    final completer = Completer<String?>();
    late final StreamSubscription<html.MessageEvent> subscription;
    subscription = html.window.onMessage.listen((event) {
      if (!_isExpectedMessage(event, parent, designerOrigin)) return;
      final session = parsePreviewSession(event.data);
      if (session != null && !completer.isCompleted) {
        completer.complete(session);
      }
    });

    parent.postMessage(createPreviewSessionRequest(), designerOrigin);
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return null;
    } finally {
      await subscription.cancel();
    }
  }

  void postPreviewStatus({required String status, String? message}) {
    _postMessage(
      jsonEncode({
        'type': 'previewStatus',
        'status': status,
        if (message != null) 'message': message,
      }),
    );
  }

  void postRouteFinished() {
    // Go back to the selected origin route
    _postMessage('routeFinished');
  }

  void _postMessage(Object message) {
    final parent = _parentWindow();
    if (parent == null) return;

    final designerOrigin = _designerOrigin();
    if (designerOrigin == null) return;

    parent.postMessage(message, designerOrigin);
  }

  void listen(AppState state, {PreviewNavigationHandler? onNavigate}) {
    final parent = _parentWindow();
    final designerOrigin = _designerOrigin();
    if (parent == null || designerOrigin == null) return;

    _messageSubscription?.cancel();
    _messageSubscription = html.window.onMessage.listen((event) async {
      if (!_isExpectedMessage(event, parent, designerOrigin)) return;
      final data = event.data;
      if (data is! String) return;

      final Object? decodedMessage;
      try {
        decodedMessage = jsonDecode(data);
      } catch (_) {
        return;
      }
      if (decodedMessage is! Map<String, dynamic>) return;

      final messageContent = decodedMessage;
      if (messageContent['type'] == 'previewNavigate') {
        if (!messageContent.keys.every(
              (key) => const {'type', 'route', 'extra', 'data'}.contains(key),
            ) ||
            (messageContent['route'] != null &&
                messageContent['route'] is! String) ||
            (messageContent['extra'] != null &&
                messageContent['extra'] is! String) ||
            (messageContent['data'] != null &&
                messageContent['data'] is! String)) {
          return;
        }
        await onNavigate?.call(messageContent['route'] as String?);
        return;
      }

      if (messageContent.containsKey('type') ||
          messageContent['id'] is! String ||
          messageContent['user_id'] is! String) {
        return;
      }

      state.updateStudy(Study.fromJson(messageContent));
    });
  }
}
