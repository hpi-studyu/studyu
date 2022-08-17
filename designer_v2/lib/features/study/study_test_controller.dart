import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_test_scaffold.dart';
import 'package:studyu_designer_v2/features/study/study_test_state.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

abstract class PlatformController {
  final String studyId;
  final String previewSrc;
  late Widget scaffold;

  PlatformController(this.previewSrc, this.studyId);

  void registerViews(Key key);
  void sendCmd(String command);
  void refresh();
  void listen();
  void send(String message);

  void openNewPage() {}
}

class StudyTestController extends StateNotifier<StudyTestState> {
  final Study study;
  final IAuthRepository authRepository;
  late PlatformController platformController;
  late String previewSrc;
  late Map<String, dynamic> missingRequirements;

  StudyTestController({
    required this.study,
    required this.authRepository,
  }) : super(StudyTestState(currentUser: authRepository.currentUser!)) {
    previewSrc = "$appDeepLink?";
    _missingRequirements();
    if (missingRequirements.isEmpty) {
      // requirements satisfied
      String sessionStr = authRepository.session?.persistSessionString ?? '';
      previewSrc += '&mode=preview&session=${Uri.encodeComponent(sessionStr)}&studyid=${study.id}';
    } else {
      previewSrc = '';
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
    // .hardcoded
    missingRequirements = {
      'Title': study.title,
      'Description': study.description,
      'Interventions': study.interventions,
      'Observations': study.observations,
      'Consent': study.questionnaire.questions,
    };
    missingRequirements.removeWhere((title, element) {
      //print(title + " ***** " + element.toString());
      var valid = _isValid(element);
      //print(valid);
      return valid;
    });
  }

  _isValid(dynamic element) {
    if (element is bool) {
      return element;
    }
    return element?.isNotEmpty ?? false;
  }
}

class WebController extends PlatformController {
  late html.IFrameElement iFrameElement;

  WebController(String previewSrc, String studyId) : super(previewSrc, studyId) {
    final key = UniqueKey();
    registerViews(key);
    scaffold = WebScaffold(previewSrc, studyId, key: key);
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
    // html.IFrameElement frame = html.document.getElementById("studyu_app_preview") as html.IFrameElement;
    // For debug purposes: postMessage(message, '*')
    iFrameElement.contentWindow?.postMessage(message, Uri.parse(previewSrc).host);
  }
}

// Mostly unfinished, since we only support Desktop for now
class MobileController extends PlatformController {
  MobileController(String previewSrc, studyId) : super(previewSrc, studyId) {
    scaffold = const MobileScaffold();
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

final studyTestControllerProvider = StateNotifierProvider.autoDispose
    .family<StudyTestController, StudyTestState, String>((ref, studyId) {
          final study = ref.watch(studyControllerProvider(studyId)).study.value;
          return StudyTestController(
          study: study!,
          authRepository: ref.watch(authRepositoryProvider),
        );

    }
);
