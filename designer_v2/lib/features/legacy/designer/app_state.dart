import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studyu_core/core.dart';

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

class AppState extends ChangeNotifier {
  String? _selectedStudyId;
  Study? draftStudy;
  DesignerPage _selectedDesignerPage = DesignerPage.about;

  AppState();

  String get selectedStudyId => _selectedStudyId!;

  DesignerPage get selectedDesignerPage => _selectedDesignerPage;

  set selectedDesignerPage(DesignerPage page) {
    _selectedDesignerPage = page;
    notifyListeners();
  }

  void createStudy({DesignerPage page = DesignerPage.about}) {
    draftStudy = Study.withId(Supabase.instance.client.auth.user()!.id);
    _selectedStudyId = null;
    _selectedDesignerPage = page;
    notifyListeners();
  }

  Future<void> openDesigner(String studyId, {DesignerPage page = DesignerPage.about}) async {
    draftStudy = await SupabaseQuery.getById<Study>(studyId);
    _selectedStudyId = studyId;
    _selectedDesignerPage = page;
    notifyListeners();
  }

  Future<void> openNewStudy(Study study) async {
    draftStudy = study;
    _selectedStudyId = study.id;
    notifyListeners();
  }
}
