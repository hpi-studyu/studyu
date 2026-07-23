import 'dart:convert';
import 'dart:js_interop' as js;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
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
  void updateData(String data) {
    routeInformation.data = data;
    send(data);
  }

  void send(String message);
  void openNewPage() {}
  void dispose() {}
}

class WebController extends PlatformController {
  late web.HTMLIFrameElement iFrameElement;
  final String serializedSession;
  bool _isListening = false;

  WebController(super.baseSrc, super.studyId, this.serializedSession) {
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

  String _buildPreviewUrl({
    String? route,
    String? extra,
    String? cmd,
    String? data,
  }) {
    if (baseSrc == '') return '';

    var url = baseSrc;
    if (route != null) url = "$url&route=$route";
    if (extra != null) url = "$url&extra=$extra";
    if (cmd != null) url = "$url&cmd=$cmd";
    if (data != null) {
      url = "$url&data=${Uri.encodeQueryComponent(data)}";
    }
    return url;
  }

  @override
  void generateUrl({String? route, String? extra, String? cmd, String? data}) {
    onLoadStarted?.call();
    navigationEnabled.value = false;
    routeInformation = RouteInformation(route, extra, cmd, data);
    previewSrc = _buildPreviewUrl(
      route: route,
      extra: extra,
      cmd: cmd,
      data: data,
    );
  }

  @override
  void updateData(String data) {
    routeInformation.data = data;
    previewSrc = _buildPreviewUrl(
      route: routeInformation.route,
      extra: routeInformation.extra,
      cmd: routeInformation.cmd,
      data: data,
    );
    if (_isListening) send(data);
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
          data: routeInformation.data,
        );
        return;
      }
      navigate(
        route: routeInformation.route,
        cmd: cmd,
        data: routeInformation.data,
      );
      return;
    }

    navigate(cmd: cmd, data: routeInformation.data);
    return;
  }

  String? get _appOrigin {
    final uri = Uri.tryParse(baseSrc);
    return uri == null || !uri.hasScheme || uri.host.isEmpty
        ? null
        : uri.origin;
  }

  @override
  void listen() {
    if (_isListening) return;
    _isListening = true;
    web.window.onMessage.listen((event) {
      final appOrigin = _appOrigin;
      final frameWindow = iFrameElement.contentWindow;
      if (appOrigin == null ||
          event.origin != appOrigin ||
          frameWindow == null ||
          event.source != frameWindow) {
        return;
      }

      final data = event.data.dartify();
      if (isPreviewSessionRequest(data)) {
        frameWindow.postMessage(
          createPreviewSessionMessage(serializedSession).toJS,
          appOrigin.toJS,
        );
        return;
      }
      if (data is String) {
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map<String, dynamic> &&
              parsed['type'] == 'previewStatus' &&
              parsed.keys.every(
                (key) => const {'type', 'status', 'message'}.contains(key),
              ) &&
              parsed['status'] is String &&
              (parsed['message'] == null || parsed['message'] is String)) {
            final status = parsed['status'] as String;
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
    final appOrigin = _appOrigin;
    if (appOrigin == null) return;
    iFrameElement.contentWindow?.postMessage(message.toJS, appOrigin.toJS);
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
