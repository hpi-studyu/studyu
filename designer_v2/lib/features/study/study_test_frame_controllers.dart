import 'dart:convert';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/features/study/study_test_frame_views.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:web/web.dart' as web;

/// Style element ID for the preview iframe styles
const String _previewStyleId = 'studyu-preview-iframe-styles';

/// Injects CSS to ensure preview iframe stays below Flutter overlays.
///
/// Uses z-index: 0 for the iframe to keep it interactive (z-index: -1 would
/// make it unclickable as it renders behind the parent's background).
/// Flutter overlays use z-index: 999999 to render above the iframe.
void _injectPreviewIframeStyles() {
  // Check if styles are already injected to make this idempotent
  if (web.document.getElementById(_previewStyleId) != null) {
    return; // Already injected
  }

  final style = web.HTMLStyleElement();
  style.id = _previewStyleId;
  // Scope styles specifically to the preview iframe to avoid affecting
  // other platform views in the application
  style.textContent = '''
    /* Target only the StudyU preview iframe container */
    .flt-platform-view:has(#studyu_app_preview) {
      position: relative !important;
      z-index: 0 !important;
    }
    /* Target the specific preview iframe by ID */
    #studyu_app_preview {
      position: relative !important;
      /* z-index: 0 keeps iframe interactive while below overlays */
      z-index: 0 !important;
    }
    /* Target iframes within the preview platform view */
    .flt-platform-view:has(#studyu_app_preview) iframe {
      position: relative !important;
      z-index: 0 !important;
    }
    /* Ensure Flutter overlays are always on top */
    .flt-overlay {
      z-index: 999999 !important;
      position: relative !important;
    }
  ''';
  web.document.head?.appendChild(style);
}

/// Removes the injected preview iframe styles from the document.
///
/// Call this when the preview is no longer needed (e.g., on dispose)
/// to clean up the DOM.
void _removePreviewIframeStyles() {
  final styleElement = web.document.getElementById(_previewStyleId);
  if (styleElement != null) {
    styleElement.remove();
  }
}

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
  void dispose() {}
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
    // Inject CSS to ensure iframe stays below Flutter overlays
    _injectPreviewIframeStyles();

    iFrameElement = web.HTMLIFrameElement()
      ..id = 'studyu_app_preview'
      ..src = previewSrc
      ..style.border = 'none'
      ..style.position = 'relative'
      // z-index: 0 keeps iframe interactive while below Flutter overlays
      ..style.zIndex = '0';

    iFrameElement.onLoad.listen((_) {
      onConnected?.call();
    });

    iFrameElement.onError.listen((_) {
      onError?.call(tr.preview_overlay_could_not_load);
    });

    ui.platformViewRegistry.registerViewFactory(
      '$studyId$key',
      (int viewId) => iFrameElement
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'relative'
        // z-index: 0 keeps iframe interactive while below Flutter overlays
        ..style.zIndex = '0',
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
    if (iFrameElement.src != previewSrc) {
      iFrameElement.src = previewSrc;
    }
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
                onError?.call(tr.preview_overlay_preview_not_opened);
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

  @override
  void dispose() {
    // Clean up injected styles when the controller is disposed
    _removePreviewIframeStyles();
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
