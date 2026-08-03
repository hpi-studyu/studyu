import 'dart:async';
import 'dart:convert';

import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import "package:universal_html/html.dart" as html;

typedef PreviewNavigationHandler = Future<void> Function(String? route);
typedef PreviewStudyHandler = void Function(Study study);

class IFrameHelper {
  // The listener must outlive LoadingScreen so loaded preview routes keep
  // receiving live study updates from the Designer.
  static StreamSubscription<html.MessageEvent>? _messageSubscription;
  Completer<Study?>? _previewStudyCompleter;

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

  Future<Study?> requestPreviewStudy() async {
    final parent = _parentWindow();
    final designerOrigin = _designerOrigin();
    if (parent == null || designerOrigin == null) return null;

    final completer = Completer<Study?>();
    _previewStudyCompleter = completer;
    parent.postMessage(createPreviewStudyRequest(), designerOrigin);
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return null;
    } finally {
      if (identical(_previewStudyCompleter, completer)) {
        _previewStudyCompleter = null;
      }
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

  void listen(
    AppState state, {
    PreviewNavigationHandler? onNavigate,
    PreviewStudyHandler? onStudy,
  }) {
    final parent = _parentWindow();
    final designerOrigin = _designerOrigin();
    if (parent == null || designerOrigin == null) return;

    _messageSubscription?.cancel();
    _messageSubscription = html.window.onMessage.listen((event) async {
      if (!_isExpectedMessage(event, parent, designerOrigin)) return;
      final data = event.data;

      final serializedStudy = parsePreviewStudy(data);
      if (serializedStudy != null) {
        try {
          final decodedStudy = jsonDecode(serializedStudy);
          if (decodedStudy is! Map<String, dynamic>) return;
          final study = Study.fromJson(decodedStudy);
          state.updateStudy(study);
          onStudy?.call(study);
          final completer = _previewStudyCompleter;
          if (completer != null && !completer.isCompleted) {
            completer.complete(study);
          }
        } catch (_) {
          return;
        }
        return;
      }

      if (data is! String) return;

      final Object? decodedMessage;
      try {
        decodedMessage = jsonDecode(data);
      } catch (_) {
        return;
      }
      if (decodedMessage is! Map<String, dynamic>) return;

      if (decodedMessage['type'] == 'previewNavigate') {
        if (!decodedMessage.keys.every(
              (key) => const {'type', 'route', 'extra', 'data'}.contains(key),
            ) ||
            (decodedMessage['route'] != null &&
                decodedMessage['route'] is! String) ||
            (decodedMessage['extra'] != null &&
                decodedMessage['extra'] is! String) ||
            (decodedMessage['data'] != null &&
                decodedMessage['data'] is! String)) {
          return;
        }
        await onNavigate?.call(decodedMessage['route'] as String?);
      }
    });
  }
}
