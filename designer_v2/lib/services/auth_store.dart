import 'package:flutter/material.dart';
import 'package:studyu_core/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


abstract class IAuthServiceDelegate {
  void onLogin();
  void onLogout();
}

//final authProvider = StateNotifierProvider<AuthService, AuthRepository>((ref) {return AuthService();});

class AuthRepository {
  // Backend client providing authentication APIs
  //final SupabaseClient supabaseClient;
  //const AuthRepository({required this.supabaseClient});
  // todo refactor this class to make it more useful
  final bool loggedIn;
  const AuthRepository({required this.loggedIn});
}
//final authService = StateNotifierProvider((ref) => AuthService(ref.read));
final authServiceProvider = StateNotifierProvider<AuthService, AuthRepository?>((ref) => AuthService());

class AuthService extends StateNotifier<AuthRepository?> {
  AuthService() : super(null);
  //final Reader _read;

  bool skippedLogin = false;
  String? authError;
  //SupabaseClient get client => client;
  bool get isLoggedIn => client.auth.session() != null;
  User? get currentUser => client.auth.user();

  //AuthService(super.state);

  // Optional listener interested in authentication state updates
  IAuthServiceDelegate? delegate;

  // TODO: remove later
  void skipLogin() {
    skippedLogin = true;
    state = const AuthRepository(loggedIn: true);
    delegate?.onLogin();
  }

  // TODO real implementation
  // what is the difference to signOut?
  void logout() {
    skippedLogin = false;
    state = const AuthRepository(loggedIn: false);
    delegate?.onLogout();
  }

  // What is this used for?
  void registerAuthListener() {
    client.auth.onAuthStateChange((event, session) {
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
    final res = await client.auth.signIn(email: email, password: password);
    if (res.error != null) {
      authError = res.error?.message;
    } else {
      state = const AuthRepository(loggedIn: true);
    }
  }

  Future<void> signUp(String email, String password) async {
    final res = await client.auth.signUp(email, password);
    if (res.error != null) {
      authError = res.error?.message;
    }
    await signIn(email, password);
  }

  Future<void> signOut() async {
    //final res = await _read(authProvider).auth.signOut();
    final res = await client.auth.signOut();
    if (res.error != null) {
      authError = res.error?.message;
    }
    state = const AuthRepository(loggedIn: false);
  }
}
