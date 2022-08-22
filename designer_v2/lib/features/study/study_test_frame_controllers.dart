import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';

abstract class PlatformController {
  final String studyId;
  final String previewSrc;
  late Widget frameWidget;

  PlatformController(this.previewSrc, this.studyId);

  void registerViews(Key key);
  void sendCmd(String command);
  void refresh();
  void listen();
  void send(String message);
  void openNewPage() {}

  void reset() {
    sendCmd("reset");
  }
}

class WebController extends PlatformController {
  late html.IFrameElement iFrameElement;

  WebController(String previewSrc, String studyId) : super(previewSrc, studyId) {
    final key = UniqueKey();
    registerViews(key);
    frameWidget = WebFrame(previewSrc, studyId, key: key);
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
  void sendCmd(String command) {
    String localPreviewSrc = "$previewSrc&cmd=$command";
    iFrameElement.src = localPreviewSrc;
  }

  @override
  void refresh() {
    iFrameElement.src = previewSrc;
  }

  @override
  void openNewPage() {
    js.context.callMethod('open', [previewSrc]);
  }

  @override
  void listen() {
    html.window.onMessage.listen((event) {
      var data = event.data;
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
  void sendCmd(String command) {
    throw UnimplementedError();
  }

  @override
  void openNewPage() {
    throw UnimplementedError();
  }

  @override
  void refresh() {
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
}
