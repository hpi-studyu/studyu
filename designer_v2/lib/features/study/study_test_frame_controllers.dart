// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';

class RouteInformation {
  String? route;
  String? extra;
  String? cmd;
  String? data;

  RouteInformation(this.route, this.extra, this.cmd, this.data);

  @override
  String toString() {
    return 'RouteInformation{route: $route, extra: $extra, cmd: $cmd, data: $data}';
  }
}

abstract class PlatformController {
  final String studyId;
  final String baseSrc;
  late String previewSrc;
  late RouteInformation routeInformation;
  late Widget frameWidget;

  PlatformController(this.baseSrc, this.studyId);

  void activate();
  void registerViews(Key key);
  void generateUrl({String? route, String? extra, String? cmd, String? data});
  void navigate({String? route, String? extra, String? cmd, String? data});
  void refresh({String? cmd});
  void listen();
  void send(String message);
  void openNewPage() {}
}

class WebController extends PlatformController {
  late html.IFrameElement iFrameElement;

  WebController(super.baseSrc, super.studyId) {
    super.frameWidget = Container();
    routeInformation = RouteInformation(null, null, null, null);
  }

  @override
  activate() {
    if (baseSrc == '') return;
    final key = UniqueKey();
    // print("Register view with: $previewSrc");
    registerViews(key);
    frameWidget = WebFrame(previewSrc, studyId, key: key);
  }

  @override
  void registerViews(Key key) {
    iFrameElement = html.IFrameElement()
      ..id = 'studyu_app_preview'
      ..src = previewSrc
      ..style.border = 'none';

    ui_web.platformViewRegistry.registerViewFactory('$studyId$key', (int viewId) => iFrameElement);
  }

  @override
  generateUrl({String? route, String? extra, String? cmd, String? data}) {
    routeInformation = RouteInformation(route, extra, cmd, data);
    if (baseSrc == '') {
      previewSrc = '';
      return;
    }
    previewSrc = baseSrc;
    if (route != null) {
      previewSrc = "$previewSrc&route=$route";
    }
    if (extra != null) {
      previewSrc = "$previewSrc&extra=$extra";
    }
    if (cmd != null) {
      previewSrc = "$previewSrc&cmd=$cmd";
    }
    if (data != null) {
      previewSrc = "$previewSrc&data=$data";
    }
  }

  @override
  void navigate({String? route, String? extra, String? cmd, String? data}) {
    generateUrl(route: route, extra: extra, cmd: cmd, data: data);

    //html.IFrameElement? frame = html.document.getElementById("studyu_app_preview") as html.IFrameElement?;
    //if (frame != null) {
    // iFrameElement = frame;
    if (iFrameElement.src != previewSrc) {
      print("*********NAVIGATE TO: $previewSrc");
      iFrameElement.src = previewSrc;
      //iFrameElement.src = newPrev;
    } /* else {
       print("Same link detected");
      } */
    // }
  }

  @override
  void refresh({String? cmd}) {
    if (routeInformation.route != null) {
      if (routeInformation.extra != null) {
        navigate(route: routeInformation.route, extra: routeInformation.extra, cmd: cmd);
        return;
      }
      navigate(route: routeInformation.route, cmd: cmd);
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
        print("Designer: Route finished");
        refresh();
      }
    });
  }

  @override
  void send(String message) {
    // For debug purposes: postMessage(message, '*')
    // print("[Preview]: Sent message: " + message);
    iFrameElement.contentWindow?.postMessage(message, env.appUrl ?? '');
  }
}

// Mostly unfinished, since we only support Desktop for now
class MobileController extends PlatformController {
  MobileController(super.previewSrc, super.studyId) {
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
  void navigate({String? route, String? extra, String? cmd, String? data}) {
    throw UnimplementedError();
  }

  @override
  void activate() {
    throw UnimplementedError();
  }

  @override
  void generateUrl({String? route, String? extra, String? cmd, String? data}) {
    throw UnimplementedError();
  }
}
