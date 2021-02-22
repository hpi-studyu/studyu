import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
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
  Future<ParseResponse> Function() _researcherDashboardQuery;

  AppState();

  String get selectedStudyId => _selectedStudyId;

  bool get isDesigner => draftStudy != null;

  Future<ParseResponse> Function() get researcherDashboardQuery {
    // _researcherDashboardQuery should always be initialized, but only after ParseInit
    return _researcherDashboardQuery ??= ParseStudy().getResearcherDashboardStudies;
  }

  void reloadResearcherDashboard() => _researcherDashboardQuery = ParseStudy().getResearcherDashboardStudies;

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
    reloadResearcherDashboard();
    notifyListeners();
  }

  void reloadStudies() {
    reloadResearcherDashboard();
    notifyListeners();
  }
}
