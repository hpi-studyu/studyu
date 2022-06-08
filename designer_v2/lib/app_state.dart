import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AppState extends ChangeNotifier {
  bool skippedLogin = false;
  String? authError;

  // ignore: prefer_function_declarations_over_variables
  Future<List<Study>> Function() researcherDashboardQuery = () => Study.getResearcherDashboardStudies();

  AppState();

  bool get loggedIn => Supabase.instance.client.auth.session() != null;
  User? get user => Supabase.instance.client.auth.user();

  void skipLogin() {
    skippedLogin = true;
    notifyListeners();
  }

  void reloadResearcherDashboard() => researcherDashboardQuery = () => Study.getResearcherDashboardStudies();

  void reloadStudies() {
    reloadResearcherDashboard();
    notifyListeners();
  }

  void registerAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange((event, session) {
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
        case AuthChangeEvent.tokenRefreshed:
          break;
      }
      reloadResearcherDashboard();
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    final res = await Supabase.instance.client.auth.signIn(email: email, password: password);
    if (res.error != null) {
      authError = res.error?.message;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    final res = await Supabase.instance.client.auth.signUp(email, password);
    if (res.error != null) {
      authError = res.error?.message;
      notifyListeners();
    }
    await signIn(email, password);
  }

  Future<void> signInWithProvider(Provider provider, String scopes) async {
    await Supabase.instance.client.auth
        .signInWithProvider(provider, options: AuthOptions(scopes: scopes, redirectTo: authRedirectToUrl));
  }

  Future<void> signOut() async {
    final res = await Supabase.instance.client.auth.signOut();
    if (res.error != null) {
      authError = res.error?.message;
      notifyListeners();
    }
  }
}
