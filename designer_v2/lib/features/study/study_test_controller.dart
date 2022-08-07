import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/study/study_test_scaffold.dart';
import 'package:studyu_designer_v2/features/study/study_test_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';

abstract class PlatformController {
  final String studyId;
  final String previewSrc;
  late Widget scaffold;

  PlatformController(this.previewSrc, this.studyId);

  void registerViews();
  void sendCmd(String command);
  void refresh();
  void listen();
  void send(String message);

  void openNewPage() {}
}

class StudyTestController extends StateNotifier<StudyTestState> {
  String previewSrc = 'https://studyu-app-v2--pr143-dev-designer-v2-prev-6dl0nxo1.web.app/';
  // todo change on merge
  //String previewSrc = 'https://studyu-app-v2.web.app/';
  // String previewSrc = 'http://localhost:12345/';

  final IAuthRepository authRepository;
  late PlatformController platformController;
  final Study study;

  StudyTestController({
    required this.study,
    required this.authRepository,
  }) : super(StudyTestState(currentUser: authRepository.currentUser!)) {
    List<dynamic> missingRequirements = _missingRequirements();
    if (missingRequirements.isEmpty) {
      // requirements satisfied
      String sessionStr = authRepository.session?.persistSessionString ?? '';
      previewSrc += '?mode=preview&session=${Uri.encodeComponent(sessionStr)}&studyid=${study.id}';
    } else {
      // todo show modal and add error
      if (kDebugMode) {
        print("Requirements not satisfied: $missingRequirements");
      }
    }
    _selectPlatform();
  }

  _selectPlatform() {
    if (!kIsWeb) {
      // Mobile could be built with the webview_flutter package
      platformController = MobileController(previewSrc, study.id);
    } else {
      // Desktop and Web
      platformController = WebController(previewSrc, study.id);
    }
  }

  // Check if the study satisfies the requirements to be previewed
  // Todo we might also include this check before publishing a study
  _missingRequirements() {
    List<dynamic> conditions = [
      study.title,
      study.description,
      study.interventions,
      study.hasEligibilityCheck,
      study.eligibilityCriteria,
      study.observations,
      study.consent,
    ];
    conditions.removeWhere((element) => _isValid(element));
    return conditions;
  }

  _isValid(dynamic val) {
    if (val is bool) {
      return val;
    }
    // todo check for custom class and throw error
    return val?.isNotEmpty ?? false;
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
          ..style.border = 'none'
    );
  }

  @override
  void sendCmd(String command) {
    html.IFrameElement iFrameElement = html.document.getElementById("studyu_app_preview")
    as html.IFrameElement;
    String localPreviewSrc = "$previewSrc&cmd=$command";
    iFrameElement.src = localPreviewSrc;
  }

  @override
  void refresh() {
    html.IFrameElement iFrameElement = html.document.getElementById("studyu_app_preview")
    as html.IFrameElement;
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
    html.IFrameElement frame = html.document.getElementById("studyu_app_preview")
        as html.IFrameElement;
    // For debug purposes: postMessage(message, '*')
    frame.contentWindow?.postMessage(message, Uri.parse(previewSrc).host);
  }
}

// Mostly unfinished, since we only support Desktop for now
class MobileController extends PlatformController {
  MobileController(String previewSrc, studyId) : super(previewSrc, studyId) {
    scaffold = const MobileScaffold();
  }

  @override
  void sendCmd(String command) {
  }

  @override
  void openNewPage() {
  }

  @override
  void refresh() {
  }

  @override
  void registerViews() {
  }

  @override
  void listen() {
  }

  @override
  void send(String message) {
  }
}

final studyTestControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyTestController, StudyTestState, Study>(
        (ref, study) => StudyTestController(
          study: study,
          authRepository: ref.watch(authRepositoryProvider),
        )
);
