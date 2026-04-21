import 'dart:convert';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:web/web.dart' as web;

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
  final ValueNotifier<bool> navigationEnabled = ValueNotifier(false);
  late String previewSrc;
  late RouteInformation routeInformation;
  late Widget frameWidget;
  VoidCallback? onLoadStarted;
  VoidCallback? onConnected;
  VoidCallback? onLoading;
  VoidCallback? onReady;
  ValueChanged<String>? onError;

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
  late web.HTMLIFrameElement iFrameElement;
  bool _isListening = false;

  WebController(super.baseSrc, super.studyId) {
    super.frameWidget = Container();
    routeInformation = RouteInformation(null, null, null, null);
  }

  @override
  void activate() {
    if (baseSrc == '') return;
    final key = UniqueKey();
    registerViews(key);
    frameWidget = WebFrame(previewSrc, studyId, key: key);
  }

  @override
  void registerViews(Key key) {
    iFrameElement = web.HTMLIFrameElement()
      ..id = 'studyu_app_preview'
      ..src = previewSrc
      ..style.border = 'none';

    iFrameElement.onLoad.listen((_) {
      onConnected?.call();
    });

    iFrameElement.onError.listen((_) {
      onError?.call('The StudyU app preview could not be loaded.');
    });

    ui.platformViewRegistry.registerViewFactory(
      '$studyId$key',
      (int viewId) => iFrameElement
        ..style.width = '100%'
        ..style.height = '100%',
    );
  }

  @override
  void generateUrl({String? route, String? extra, String? cmd, String? data}) {
    onLoadStarted?.call();
    navigationEnabled.value = false;
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
    if (navigationEnabled.value && cmd == null) {
      routeInformation = RouteInformation(route, extra, cmd, data);
      send(
        jsonEncode({
          'type': 'previewNavigate',
          if (route != null) 'route': route,
          if (extra != null) 'extra': extra,
          if (data != null) 'data': data,
        }),
      );
      navigationEnabled.value = false;
      return;
    }

    generateUrl(route: route, extra: extra, cmd: cmd, data: data);

    //html.IFrameElement? frame = html.document.getElementById("studyu_app_preview") as html.IFrameElement?;
    //if (frame != null) {
    // iFrameElement = frame;
    if (iFrameElement.src != previewSrc) {
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
        navigate(
          route: routeInformation.route,
          extra: routeInformation.extra,
          cmd: cmd,
        );
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
    js.globalContext.callMethod('open'.toJS, previewSrc.toJS);
  }

  @override
  void listen() {
    if (_isListening) return;
    _isListening = true;
    web.window.onMessage.listen((event) {
      final data = event.data.dartify();
      if (data is String) {
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map<String, dynamic> &&
              parsed['type'] == 'previewStatus') {
            final status = parsed['status'] as String?;
            final message = parsed['message'] as String?;
            switch (status) {
              case 'loading':
                onLoading?.call();
                return;
              case 'loaded':
                navigationEnabled.value = true;
                onReady?.call();
                return;
              case 'error':
                navigationEnabled.value = false;
                onError?.call(
                  message ??
                      'The StudyU app preview could not be opened right now.',
                );
                return;
            }
          }
        } catch (_) {
          // Fall through to legacy string handling.
        }
      }
      if (data == 'previewConnected') {
        onConnected?.call();
        return;
      }
      if (data == 'previewReady') {
        navigationEnabled.value = true;
        onReady?.call();
        return;
      }
      if (data == 'routeFinished') {
        navigationEnabled.value = true;
        onReady?.call();
        // debugLog("Preview route finished");
      }
    });
  }

  @override
  void send(String message) {
    iFrameElement.contentWindow?.postMessage(
      message.toJS,
      (env.appUrl ?? '').toJS,
    );
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
