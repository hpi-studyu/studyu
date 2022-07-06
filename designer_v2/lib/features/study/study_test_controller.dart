import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_test_scaffold.dart';
import 'package:studyu_designer_v2/features/study/study_test_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

abstract class PlatformController {
  final String studyId;
  final String previewSrc;
  late Widget scaffold;

  PlatformController(this.previewSrc, this.studyId);

  void registerViews();

  void listen();

  void send();
}

class StudyTestController extends StateNotifier<StudyTestState> {
  String previewSrc = 'https://studyu-app-v2.web.app/';

  final IAuthRepository authRepository;
  late final PlatformController platformController;
  final String studyId;

  StudyTestController({
    required this.studyId,
    required this.authRepository,
  }) : super(StudyTestState(currentUser: authRepository.currentUser!)) {
    _modifySrc();
    _selectPlatform();
  }

  _selectPlatform() {
    // We can also use defaultTargetPlatform to detect running environment
    // mobile: (TargetPlatform.iOS || TargetPlatform.android)
    // Desktop: (linux, macOS, windows)
    // else: Web
    if (!kIsWeb) {
      // just check if run on the web or not
      // Mobile
      // Could be built with the webview_flutter package
      platformController = MobileController(previewSrc, studyId);
    } else {
      platformController = WebController(previewSrc, studyId);
    }
  }

  _modifySrc() {
    String sessionStr = authRepository.session?.persistSessionString ?? '';
    previewSrc +=
        '?mode=preview&session=${Uri.encodeComponent(sessionStr)}&studyid=$studyId';
  }
}

class WebController extends PlatformController {
  WebController(String previewSrc, String studyId) : super(previewSrc, studyId) {
    registerViews();
    scaffold = WebScaffold(previewSrc, studyId);
  }

  @override
  void registerViews() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        studyId,
        (int viewId) => html.IFrameElement()
          ..id = 'studyu_app_preview'
          ..src = previewSrc
          ..style.border = 'none');
  }

  @override
  void listen() {
    // todo seems to be triggering two times. Is the message getting sent twice or is the listener started twice?
    html.window.onMessage.listen((event) {
      var data = event.data;
    });
  }

  @override
  void send() {
    html.IFrameElement iw = html.document.getElementById("studyu_app_preview")
        as html.IFrameElement;
    iw.contentWindow?.postMessage('designer message', "*");
    print("designer send");
  }
}

class MobileController extends PlatformController {
  MobileController(String previewSrc, studyId) : super(previewSrc, studyId) {
    //throw UnimplementedError();
    scaffold = const MobileScaffold();
  }

  @override
  void registerViews() {
    // implement _registerViews
  }

  @override
  void listen() {
    // implement listen
  }

  @override
  void send() {
    // implement send
  }
}

final studyTestControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyTestController, StudyTestState, StudyID>(
        (ref, studyId) => StudyTestController(
              studyId: studyId,
              authRepository: ref.watch(authRepositoryProvider),
            ));
