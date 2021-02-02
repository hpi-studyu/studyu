import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';

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

  void createStudy() {
    draftStudy = StudyBase.designerDefault();
    _selectedStudyId = null;
    notifyListeners();
  }

  Future<void> openStudy(String studyId, {DesignerPage page = DesignerPage.about}) async {
    final res = await StudyQueries.getStudyWithDetailsByStudyId(studyId);
    draftStudy = res.results.first;
    _selectedStudyId = studyId;
    _selectedDesignerPage = page;
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
