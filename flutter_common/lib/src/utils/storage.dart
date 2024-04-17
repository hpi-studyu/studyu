import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const FlutterSecureStorage storage = FlutterSecureStorage();

class SupabaseStorage extends LocalStorage {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    return SecureStorage.containsKey(supabasePersistSessionKey);
  }

  @override
  Future<String?> accessToken() async {
    return SecureStorage.read(supabasePersistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    return SecureStorage.write(supabasePersistSessionKey, persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    return SecureStorage.delete(supabasePersistSessionKey);
  }
}

class SecureStorage {
  static Future<bool> containsKey(String key) async {
    return await storage.containsKey(key: key);
  }

  static Future<void> write(String key, String value) async {
    return await storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await storage.read(key: key);
  }

  static Future<bool?> readBool(String key) async {
    final readValue = await storage.read(key: key);
    if (readValue == null) return null;
    return bool.parse(readValue);
  }

  static Future<void> delete(String key) async {
    return await storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    return storage.deleteAll();
  }

  /// Migrates all non-null key-value pairs from SharedPreferences to FlutterSecureStorage.
  ///
  /// This function retrieves all keys from SharedPreferences, reads the corresponding values,
  /// and writes them to FlutterSecureStorage if they are not null.
  ///
  /// This function is asynchronous and returns a Future that completes when the migration is done.
  static Future<void> migrateSharedPreferencesToSecureStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      final Object? value = prefs.get(key);
      if (value is String || value is bool) {
        await storage.write(key: key, value: value.toString());
        await prefs.remove(key);
        StudyULogger.info("Migrated key $key from SharedPreferences to FlutterSecureStorage.");
      }
    }
  }
}
