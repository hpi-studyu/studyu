import 'dart:async';
import 'dart:convert';

import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart' show Study;
import 'package:studyu_core/env.dart' as env;
import "package:universal_html/html.dart" as html;

typedef PreviewNavigationHandler = Future<void> Function(String? route);

class IFrameHelper {
  // The listener must outlive LoadingScreen so loaded preview routes keep
  // receiving live study updates from the Designer.
  static StreamSubscription<html.MessageEvent>? _messageSubscription;

  String? _designerOrigin() {
    final referrerObject = html.document.referrer as Object?;
    final referrer = referrerObject is String ? referrerObject : null;
    if (referrer != null && referrer.isNotEmpty) {
      final uri = Uri.tryParse(referrer);
      if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
        return uri.origin;
      }
    }
    return env.designerUrl;
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
    final html.WindowBase? parent;
    try {
      parent = html.window.parent;
    } catch (_) {
      return;
    }
    if (parent == null) return;

    final designerOrigin = _designerOrigin();
    if (designerOrigin == null) return;

    parent.postMessage(message, designerOrigin);
  }

  void listen(AppState state, {PreviewNavigationHandler? onNavigate}) {
    _messageSubscription?.cancel();
    _messageSubscription = html.window.onMessage.listen((event) async {
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
