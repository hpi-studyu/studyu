import 'dart:convert';

/// Minimal contract your real backend adapter should implement.
abstract class UserPrefsApi {
  Future<Map<String, dynamic>> fetch();          // returns the whole user.preferences JSON
  Future<void> save(Map<String, dynamic> prefs);  // replaces/merges preferences on server
}

/// TEMP in-memory fallback so everything runs now.
/// Swap this with your HTTP/Supabase adapter later.
class InMemoryUserPrefsApi implements UserPrefsApi {
  Map<String, dynamic> _prefs = {};
  @override
  Future<Map<String, dynamic>> fetch() async => jsonDecode(jsonEncode(_prefs)) as Map<String, dynamic>;
  @override
  Future<void> save(Map<String, dynamic> prefs) async {
    _prefs = Map<String, dynamic>.from(prefs);
  }
}
