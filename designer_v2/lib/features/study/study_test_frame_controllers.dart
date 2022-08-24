import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';

class RouteInformation {
  String? route;
  String? extra;
  String? cmd;

  RouteInformation(this.route, this.extra, this.cmd);
}

abstract class PlatformController {
  final String studyId;
  final String previewSrc;
  late RouteInformation routeInformation;
  late Widget frameWidget;

  PlatformController(this.previewSrc, this.studyId);

  void registerViews(Key key);
  void navigate({String? page, String? extra, String? cmd});
  void refresh({String? cmd});
  void listen();
  void send(String message);
  void openNewPage() {}
}

class WebController extends PlatformController {
  late html.IFrameElement iFrameElement;

  WebController(String previewSrc, String studyId) : super(previewSrc, studyId) {
    final key = UniqueKey();
    registerViews(key);
    frameWidget = WebFrame(previewSrc, studyId, key: key);
    routeInformation = RouteInformation(null, null, null);
  }

  @override
  void registerViews(Key key) {
    iFrameElement = html.IFrameElement()
      ..id = 'studyu_app_preview'
      ..src = previewSrc
      ..style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        '$studyId$key',
            (int viewId) => iFrameElement
    );
  }

  @override
  void navigate({String? page, String? extra, String? cmd}) {
    String newPrev = previewSrc;
    if (page != null) {
      routeInformation.route = page;
      newPrev = "$newPrev&route=$page";
    } else {
      routeInformation.route = null;
    }
    if (extra != null) {
      routeInformation.extra = extra;
      newPrev = "$newPrev&extra=$extra";
    } else {
      routeInformation.extra = null;
    }
    if (cmd != null) {
      routeInformation.cmd = cmd;
      newPrev = "$newPrev&cmd=$cmd";
    } else {
      routeInformation.cmd = null;
    }
    print("*********NAVIGATE TO: $cmd $newPrev");
    if (iFrameElement.src != newPrev) {
      iFrameElement.src = newPrev;
    } else {
      print("Same link detected");
    }
  }

  @override
  void refresh({String? cmd}) {
    if (routeInformation.route != null) {
      if (routeInformation.extra != null) {
        navigate(page: routeInformation.route, extra: routeInformation.extra, cmd: cmd);
        return;
      }
      navigate(page: routeInformation.route, cmd: cmd);
      return;
    }
    navigate(cmd: cmd);
    return;
  }

  @override
  void openNewPage() {
    js.context.callMethod('open', [previewSrc]);
  }

  @override
  void listen() {
    html.window.onMessage.listen((event) {
      var data = event.data;
      if (data == 'routeFinished') {
        refresh();
      }
    });
  }

  @override
  void send(String message) {
    //html.IFrameElement frame = html.document.getElementById("studyu_app_preview") as html.IFrameElement;
    // For debug purposes: postMessage(message, '*')
    iFrameElement.contentWindow?.postMessage(message, Uri.parse(previewSrc).host);
  }
}

// Mostly unfinished, since we only support Desktop for now
class MobileController extends PlatformController {
  MobileController(String previewSrc, studyId) : super(previewSrc, studyId) {
    frameWidget = const MobileFrame();
  }

  @override
  void openNewPage() {
    throw UnimplementedError();
  }

  @override
  void refresh({String? cmd}) {
    throw UnimplementedError();
  }

  @override
  void registerViews(Key key) {
    throw UnimplementedError();
  }

  @override
  void listen() {
    throw UnimplementedError();
  }

  @override
  void send(String message) {
    throw UnimplementedError();
  }

  @override
  void navigate({String? page, String? extra, String? cmd}) {
    throw UnimplementedError();
  }

}
