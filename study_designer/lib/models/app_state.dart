import 'package:flutter/material.dart';
import 'package:postgrest/postgrest.dart';
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
  Study draftStudy;
  DesignerPage _selectedDesignerPage = DesignerPage.about;
  Future<PostgrestResponse> Function() _researcherDashboardQuery;

  AppState();

  String get selectedStudyId => _selectedStudyId;

  bool get isDesigner => draftStudy != null;

  Future<PostgrestResponse> Function() get researcherDashboardQuery {
    // _researcherDashboardQuery should always be initialized, but only after ParseInit
    return _researcherDashboardQuery ??= Study().getResearcherDashboardStudies;
  }

  void reloadResearcherDashboard() => _researcherDashboardQuery = Study().getResearcherDashboardStudies;

  DesignerPage get selectedDesignerPage => _selectedDesignerPage;

  set selectedDesignerPage(DesignerPage page) {
    _selectedDesignerPage = page;
    notifyListeners();
  }

  void createStudy({DesignerPage page = DesignerPage.about}) {
    draftStudy = Study.designerDefault();
    _selectedStudyId = null;
    _selectedDesignerPage = page;
    notifyListeners();
  }

  Future<void> openStudy(String studyId, {DesignerPage page = DesignerPage.about}) async {
    final res = await Study().getById(studyId);
    draftStudy = Study.fromJson(res.data as Map<String, dynamic>);
    _selectedStudyId = studyId;
    _selectedDesignerPage = page;
    notifyListeners();
  }

  Future<void> openNewStudy(Study study) async {
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
