import 'dart:convert';
import 'dart:html' as html;

import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;

class IFrameHelper {

void postRouteFinished() {
  // Go back to the selected origin route
  html.window.parent.postMessage('routeFinished', env.designerUrl);
}

void listen(AppState state) {
  html.window.onMessage.listen((event) {
    final message = event.data as String;
    final messageContent = jsonDecode(message) as Map<String, dynamic>;
    // if (messageContent['intervention'] != null) {
    //  print(messageContent['intervention']);
    print("AppListen: " + messageContent.toString());
    state.updateStudy(Study.fromJson(messageContent));
    // }
  });
}
}