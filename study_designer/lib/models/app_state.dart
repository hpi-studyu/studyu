import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';

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
  save,
}

class AppState extends ChangeNotifier {
  String _selectedStudyId;
  StudyBase draftStudy;
  DesignerPage _selectedDesignerPage = DesignerPage.about;
  ParseStudy _parseStudyInstance;

  AppState();

  String get selectedStudyId => _selectedStudyId;

  bool get isDesigner => draftStudy != null;

  ParseStudy get parseStudyInstance {
    // _parseStudyInstance should always be initialized, but only after ParseInit
    return _parseStudyInstance ??= ParseStudy();
  }

  DesignerPage get selectedDesignerPage => _selectedDesignerPage;

  set selectedDesignerPage(DesignerPage page) {
    _selectedDesignerPage = page;
    notifyListeners();
  }

  void createStudy({DesignerPage page = DesignerPage.about}) {
    draftStudy = StudyBase.designerDefault();
    _selectedStudyId = null;
    _selectedDesignerPage = page;
    notifyListeners();
  }

  Future<void> openStudy(String studyId, {DesignerPage page = DesignerPage.about}) async {
    final res = await ParseStudy().getStudyById(studyId);
    draftStudy = res.results.first;
    _selectedStudyId = studyId;
    _selectedDesignerPage = page;
    notifyListeners();
  }

  Future<void> openNewStudy(StudyBase study) async {
    draftStudy = study;
    _selectedStudyId = study.id;
    notifyListeners();
  }

  void closeDesigner() {
    _selectedStudyId = null;
    draftStudy = null;
    _selectedDesignerPage = DesignerPage.about;
    _parseStudyInstance = ParseStudy();
    notifyListeners();
  }

  void reloadStudies() {
    _parseStudyInstance = ParseStudy();
    notifyListeners();
  }
}
