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

  AppState();

  String get selectedStudyId => _selectedStudyId;

  bool get isDesigner => draftStudy != null;

  DesignerPage get selectedDesignerPage => _selectedDesignerPage;

  void createStudy() {
    draftStudy = StudyBase.designerDefault();
    _selectedStudyId = null;
    notifyListeners();
  }

  Future<void> openStudy(String studyId) async {
    final res = await StudyQueries.getStudyWithDetailsByStudyId(studyId);
    draftStudy = res.results.first;
    _selectedStudyId = studyId;
    notifyListeners();
  }

  void closeDesigner() {
    _selectedStudyId = null;
    draftStudy = null;
    notifyListeners();
  }

  set selectedDesignerPage(DesignerPage page) {
    _selectedDesignerPage = page;
    notifyListeners();
  }
}
