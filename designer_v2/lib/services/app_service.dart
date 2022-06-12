import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/services/auth_store.dart';

//final authProvider = StateNotifierProvider((ref) {
//  return AuthNotifier(null);
//});
// TODO: This needs to be rewritten to use riverpod
class AppDelegate with ChangeNotifier implements IAuthServiceDelegate {
  late final SharedPreferences sharedPreferences;

  bool _isInitialized = false;
  bool _isLoggedIn = false;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;

  AppDelegate(this.sharedPreferences);

  Future<void> onAppStart() async {
    // TODO: read persistent state from local storage (session, EULA, onboarding)

    // This is just to demonstrate the splash screen is working.
    // In real-life applications, it is not recommended to interrupt the user experience by doing such things.
    await Future.delayed(const Duration(seconds: 2));

    _isInitialized = true;
    notifyListeners();
  }

  // - AuthServiceDelegate

  @override
  void onLogin() {
    _isLoggedIn = true;
    notifyListeners();
  }

  @override
  void onLogout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
