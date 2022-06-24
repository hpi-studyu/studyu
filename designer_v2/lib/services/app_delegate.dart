import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDelegate with ChangeNotifier {
  final SharedPreferences sharedPreferences;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppDelegate(this.sharedPreferences);

  Future<void> onAppStart() async {
    // TODO: read persistent state from local storage (session, EULA, onboarding)

    // This is just to demonstrate the splash screen is working.
    // In real-life applications, it is not recommended to interrupt the user experience by doing such things.
    await Future.delayed(const Duration(seconds: 2));

    _isInitialized = true;
    notifyListeners();
  }
}