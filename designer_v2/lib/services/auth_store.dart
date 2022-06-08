import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


abstract class IAuthServiceDelegate {
  void onLogin();
  void onLogout();
}


class AuthService {
  // Backend client providing authentication APIs
  final SupabaseClient supabaseClient;

  // Optional listener interested in authentication state updates
  IAuthServiceDelegate? delegate;

  bool skippedLogin = false;
  String? authError;

  AuthService({required this.supabaseClient});

  bool get isLoggedIn => supabaseClient.auth.session() != null;
  User? get currentUser => supabaseClient.auth.user();

  // TODO: remove later
  void skipLogin() {
    skippedLogin = true;
    delegate?.onLogin();
  }

  // TODO real implementation
  void logout() {
    skippedLogin = false;
    delegate?.onLogout();
  }

  // What is this used for?
  void registerAuthListener() {
    supabaseClient.auth.onAuthStateChange((event, session) {
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
    });
  }

  Future<void> signIn(String email, String password) async {
    final res = await supabaseClient.auth.signIn(email: email, password: password);
    if (res.error != null) {
      authError = res.error?.message;
    }
  }

  Future<void> signUp(String email, String password) async {
    final res = await supabaseClient.auth.signUp(email, password);
    if (res.error != null) {
      authError = res.error?.message;
    }
    await signIn(email, password);
  }

  Future<void> signOut() async {
    final res = await supabaseClient.auth.signOut();
    if (res.error != null) {
      authError = res.error?.message;
    }
  }
}
