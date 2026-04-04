import 'dart:convert';

import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart' show Study;
import 'package:studyu_core/env.dart' as env;
import "package:universal_html/html.dart" as html;

class IFrameHelper {
  String _designerOrigin() {
    final referrer = html.document.referrer;
    if (referrer.isNotEmpty) {
      final uri = Uri.tryParse(referrer);
      if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
        return uri.origin;
      }
    }
    return env.designerUrl!;
  }

  void postPreviewStatus({required String status, String? message}) {
    html.window.parent!.postMessage(
      jsonEncode({
        'type': 'previewStatus',
        'status': status,
        if (message != null) 'message': message,
      }),
      _designerOrigin(),
    );
  }

  void postRouteFinished() {
    // Go back to the selected origin route
    html.window.parent!.postMessage('routeFinished', _designerOrigin());
  }

  void listen(AppState state) {
    html.window.onMessage.listen((event) {
      final message = event.data as String;
      final messageContent = jsonDecode(message) as Map<String, dynamic>;
      state.updateStudy(Study.fromJson(messageContent));
    });
  }
}
