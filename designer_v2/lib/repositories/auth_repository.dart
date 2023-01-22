import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';
import 'package:studyu_designer_v2/utils/behaviour_subject.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';
import 'package:studyu_designer_v2/utils/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthRepository extends IAppDelegate {
  // - Authentication
  User? get currentUser;
  bool get isLoggedIn;
  Session? get session;
  late bool allowPasswordReset = false;
  Stream<User?> watchAuthStateChanges({bool emitLastEvent});
  Future<bool> signUp({required String email, required String password});
  Future<bool> signInWith({required String email, required String password});
  Future<void> signOut();
  Future<bool> resetPasswordForEmail({required String email});
  Future<bool> updateUser({required String newPassword});
  // - Lifecycle
  void dispose();
}

class AuthRepository implements IAuthRepository {
  /// The key used for persisting the user session in local storage
  static const PERSIST_SESSION_KEY = 'auth/session';

  /// Reference to the Supabase API client injected via Riverpod
  final SupabaseClient supabaseClient;

  /// Reference to shared preferences used for session storage
  final SharedPreferences sharedPreferences;

  /// A stream controller for broadcasting the currently logged in user
  /// Broadcasts null if the user is logged out
  final BehaviorSubject<User?> _authStateStreamController =
      BehaviorSubject.seeded(null);
  late final _authStateSuppressedController =
      SuppressedBehaviorSubject(_authStateStreamController);

  /// Private subscription for synchronizing with [SupabaseClient] auth state
  late final StreamSubscription<AuthState> _authSubscription;

  GoTrueClient get authClient => supabaseClient.auth;

  @override
  //Session? get session => authClient.session();
  late Session? session;

  AuthRepository({
    required this.supabaseClient,
    required this.sharedPreferences,
  }) {
    _registerAuthListener();
  }

  /// Register as a listener on [SupabaseClient] to re-expose auth state
  /// changes on the repository's stream
  void _registerAuthListener() {
    _authSubscription = supabaseClient.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      session = data.session;

      // handle auth state change
      switch (event) {
        case AuthChangeEvent.signedIn:
          // Update stream with logged in user
          _authStateStreamController.add(authClient.currentUser);
          _persistSession();
          break;
        case AuthChangeEvent.signedOut:
          // Send null to indicate that no user is available (logged out)
          _authStateStreamController.add(null);
          _resetPersistedSession();
          break;
        case AuthChangeEvent.userUpdated:
          // Update stream with new user object
          _authStateStreamController.add(authClient.currentUser);
          _persistSession();
          break;
        case AuthChangeEvent.passwordRecovery:
          //router.dispatch(RoutingIntents.passwordRecovery);
          allowPasswordReset = true;
          break;
        case AuthChangeEvent.tokenRefreshed:
          _persistSession();
          break;
        case AuthChangeEvent.userDeleted:
          break;
        case AuthChangeEvent.mfaChallengeVerified:
          break;
      }
    });
  }

  @override
  bool allowPasswordReset = false;

  @override
  User? get currentUser => _authStateStreamController.value;

  @override
  bool get isLoggedIn => currentUser != null;

  @override
  BehaviorSubject<User?> watchAuthStateChanges({emitLastEvent = true}) =>
      (emitLastEvent)
          ? _authStateStreamController
          : _authStateSuppressedController.subject;

  @override
  Future<bool> signUp({required String email, required String password}) async {
    try {
      await authClient.signUp(email: email, password: password);
      return true;
    } catch(error) {
      throw StudyUException(error.toString());
    }
  }

  @override
  Future<bool> signInWith(
      {required String email, required String password}) async {
    try {
      await authClient.signInWithPassword(email: email, password: password);
      return true;
    } catch(error) {
      throw StudyUException(error.toString());
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      await authClient.signOut();
      return true;
    } catch(error) {
      throw StudyUException(error.toString());
    }
  }

  @override
  Future<bool> resetPasswordForEmail({required String email}) async {
    try {
      await authClient.resetPasswordForEmail(email, redirectTo: env.authRedirectToUrl);
      return true;
    } catch(error) {
      throw StudyUException(error.toString());
    }
  }

  @override
  Future<bool> updateUser({required String newPassword}) async {
    try {
      await authClient.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch(error) {
      throw StudyUException(error.toString());
    }
  }

  Future<void> _persistSession() async {
    if (session != null) {
      sharedPreferences.setString(
          PERSIST_SESSION_KEY, session!.persistSessionString);
      debugLog("Saving session key ${session!.persistSessionString}");
    }
  }

  Future<void> _resetPersistedSession() async {
    if (sharedPreferences.containsKey(PERSIST_SESSION_KEY)) {
      sharedPreferences.remove(PERSIST_SESSION_KEY);
    }
    debugLog("Reset session key");
  }

  Future<bool> _recoverSession() async {
    if (!sharedPreferences.containsKey(PERSIST_SESSION_KEY)) {
      return false;
    }
    final jsonStr = sharedPreferences.getString(PERSIST_SESSION_KEY)!;
    try {
      final response = await authClient.recoverSession(jsonStr);
      debugLog('Hydrated user session: ${response.user ?? 'None'}');
      return true;
    } catch(error) {
      debugLog('Failed to recover user session: ${error.toString()}');
      return false;
    }

  }

  @override
  void dispose() {
    _authStateStreamController.close();
    _authStateSuppressedController.close();
    _authSubscription.cancel();
  }

  // - IAppDelegate

  @override
  Future<bool> onAppStart() async {
    await _recoverSession();
    return true;
  }
}

final authRepositoryProvider = riverpod.Provider<IAuthRepository>((ref) {
  final authRepository = AuthRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    authRepository.dispose();
  });
  return authRepository;
});

final currentUserProvider = riverpod.Provider<User?>((ref) {
  print("currentUserProvider");
  final authRepository = ref.watch(authRepositoryProvider);
  authRepository
      .watchAuthStateChanges(emitLastEvent: false)
      .listen((event) {
    print("currentUserProvider.dispose");
    ref.invalidateSelf();
  });
  return authRepository.currentUser;
});
