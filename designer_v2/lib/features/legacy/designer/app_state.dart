import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
//import 'package:studyu_designer_v2/features/study/study_controller_state.dart';

enum DesignerPage {
  about,
  interventions,
  eligibilityQuestions,
  eligibilityCriteria,
  observations,
  schedule,
  report,
  results,
  consent,
}

abstract class LegacyAppStateDelegate {
  void onStudyUpdate(Study study);
}

class AppState extends ChangeNotifier {
  AppState();

  String? _selectedStudyId;
  DesignerPage _selectedDesignerPage = DesignerPage.about;

  Study? _draftStudy;
  Study? get draftStudy {
    // Dirty hack so we can sync changes from [AppState.draftStudy] to
    // the new [StudyController]
    Future.delayed(
        const Duration(milliseconds: 0),
        () => updateDelegate(),
    );
    return _draftStudy;
  }
  set draftStudy(Study? study) => _draftStudy = study;
  LegacyAppStateDelegate? delegate;

  String get selectedStudyId => _selectedStudyId!;
  DesignerPage get selectedDesignerPage => _selectedDesignerPage;

  set selectedDesignerPage(DesignerPage page) {
    _selectedDesignerPage = page;
    notifyListeners();
  }

  updateDelegate() {
    if (_draftStudy != null) {
      //delegate?.onStudyUpdate(_draftStudy!);
    }
  }
}

final legacyAppStateProvider = ChangeNotifierProvider.autoDispose
    .family<AppState, StudyID>((ref, studyId) {
  final studyController = ref.watch(studyControllerProvider(studyId).notifier);
  final appState = AppState();
  //appState.delegate = studyController;
  appState._draftStudy = studyController.state.study.value;

  return appState;
});