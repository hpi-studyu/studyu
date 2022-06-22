import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthServiceDelegate {
  void onLogin();

  void onLogout();
}

@immutable
class AuthStore {
  // todo use a provider instead of static?
  // Backend client providing authentication APIs
  static late final SupabaseClient supabaseClient;

  bool get isLoggedIn => supabaseClient.auth.session() != null;

  User? get currentUser => supabaseClient.auth.user();
}

final authServiceProvider = ChangeNotifierProvider((ref) {
  return AuthServiceNotifier();
});

class AuthServiceNotifier extends ChangeNotifier {
  // Optional listener interested in authentication state updates
  IAuthServiceDelegate? delegate;
  bool skippedLogin = false;
  String? authError;

  // TODO: remove later
  void skipLogin() {
    skippedLogin = true;
    notifyListeners();
    delegate?.onLogin();
  }

  // TODO real implementation
  // use signOut instead?
  void logout() {
    skippedLogin = false;
    notifyListeners();
    delegate?.onLogout();
  }

  // What is this used for?
  void registerAuthListener() {
    AuthStore.supabaseClient.auth.onAuthStateChange((event, session) {
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
    final res = await AuthStore.supabaseClient.auth
        .signIn(email: email, password: password);
    if (res.error != null) {
      authError = res.error?.message;
    }
    delegate?.onLogin();
  }

  Future<void> signUp(String email, String password) async {
    final res = await AuthStore.supabaseClient.auth.signUp(email, password);
    if (res.error != null) {
      authError = res.error?.message;
    }
    await signIn(email, password);
  }

  Future<void> signOut() async {
    //final res = await super.state.instance.auth.signOut();
    final res = await AuthStore.supabaseClient.auth.signOut();
    if (res.error != null) {
      authError = res.error?.message;
    }
    delegate?.onLogout();
  }
}
