import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
}