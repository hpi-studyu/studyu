import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:studyou_core/core.dart';
import 'package:studyou_core/env.dart' as env;
import 'package:supabase/supabase.dart';
import 'package:url_launcher/url_launcher.dart';

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

enum AppPage {
  dashboard,
  designer,
  analytics,
}

class AppState extends ChangeNotifier {
  String _selectedStudyId;
  String _selectedNotebook;
  Study draftStudy;
  bool skippedLogin = false;
  String authError;
  String html = '<html><body>LOADING</body></html>';
  DesignerPage _selectedDesignerPage = DesignerPage.about;
  AppPage appPage = AppPage.dashboard;

  // ignore: prefer_function_declarations_over_variables
  Future<List<Study>> Function() researcherDashboardQuery = () => Study.getResearcherDashboardStudies();

  AppState();

  String get selectedStudyId => _selectedStudyId;

  String get selectedNotebook => _selectedNotebook;

  bool get isDesigner => draftStudy != null;

  bool get loggedIn => env.client.auth.session() != null;

  void skipLogin() {
    skippedLogin = true;
    notifyListeners();
  }

  void goToLoginScreen() {
    skippedLogin = false;
    notifyListeners();
  }

  void reloadResearcherDashboard() => researcherDashboardQuery = () => Study.getResearcherDashboardStudies();

  void reloadStudies() {
    reloadResearcherDashboard();
    notifyListeners();
  }

  DesignerPage get selectedDesignerPage => _selectedDesignerPage;

  set selectedDesignerPage(DesignerPage page) {
    _selectedDesignerPage = page;
    notifyListeners();
  }

  void createStudy({DesignerPage page = DesignerPage.about}) {
    appPage = AppPage.designer;
    draftStudy = Study.withId(env.client.auth.user().id);
    _selectedStudyId = null;
    _selectedDesignerPage = page;
    notifyListeners();
  }

  Future<void> openStudy(String studyId, {DesignerPage page = DesignerPage.about}) async {
    appPage = AppPage.designer;
    draftStudy = await SupabaseQuery.getById<Study>(studyId);
    _selectedStudyId = studyId;
    _selectedDesignerPage = page;
    notifyListeners();
  }

  Future<void> openNewStudy(Study study) async {
    appPage = AppPage.designer;
    draftStudy = study;
    _selectedStudyId = study.id;
    notifyListeners();
  }

  void goToDashboard() {
    appPage = AppPage.dashboard;
    _selectedStudyId = null;
    _selectedNotebook = null;
    draftStudy = null;
    _selectedDesignerPage = DesignerPage.about;
    reloadResearcherDashboard();
    notifyListeners();
  }

  void goBackToAnalytics() {
    appPage = AppPage.analytics;
    _selectedNotebook = null;
    notifyListeners();
  }

  void openAnalytics(String studyId, {String notebook}) {
    appPage = AppPage.analytics;
    _selectedStudyId = studyId;
    _selectedNotebook = notebook;
    notifyListeners();
  }

  void registerAuthListener() {
    env.client.auth.onAuthStateChange((event, session) {
      switch (event) {
        case AuthChangeEvent.signedIn:
          skippedLogin = false;
          authError = null;
          break;
        case AuthChangeEvent.signedOut:
          break;
        case AuthChangeEvent.userUpdated:
          break;
        case AuthChangeEvent.passwordRecovery:
          break;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    final res = await env.client.auth.signIn(email: email, password: password);
    if (res.error != null) {
      authError = res.error.message;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    final res = await env.client.auth.signUp(email, password);
    if (res.error != null) {
      authError = res.error.message;
      notifyListeners();
    }
  }

  Future<void> signInWithProvider(Provider provider, String scopes) async {
    final res = await env.client.auth.signIn(
      email: null,
      password: null,
      provider: provider,
      options: ProviderOptions(
          //  This is not redundant
          // ignore: avoid_redundant_argument_values
          redirectTo: env.authRedirectToUrl(isWeb: kIsWeb),
          scopes: scopes),
    );
    if (res.error != null) {
      authError = res.error.message;
      notifyListeners();
    } else {
      launch(res.url);
    }
  }

  Future<void> signOut() async {
    final res = await env.client.auth.signOut();
    if (res.error != null) {
      authError = res.error.message;
      notifyListeners();
    }
  }
}
