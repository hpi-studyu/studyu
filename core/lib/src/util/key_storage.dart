import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyStorage {
  static const String prefKeyForKey = "StudyU_MediaEncryptionKey";
  static const String pefKeyForIV = "StudyU_MediaEncryptionIV";

  static Future<KeyStorage> buildHandler() async {
    final SharedPreferences aSharedPreferences =
        await SharedPreferences.getInstance();
    return KeyStorage(aSharedPreferences);
  }

  SharedPreferences keyValueStore;

  KeyStorage(SharedPreferences aKeyValueStore) : keyValueStore = aKeyValueStore;

  void _initEncryptionKey() {
    final Key key = Key.fromSecureRandom(32);
    keyValueStore.setString(KeyStorage.prefKeyForKey, key.base64);
  }

  void _initEncryptionIV() {
    final IV iv = IV.fromSecureRandom(8);
    keyValueStore.setString(KeyStorage.pefKeyForIV, iv.base64);
  }

  T _getSharedPreferenceValue<T>(void Function() initIfNotExist,
      String accessKey, T Function(String) convertRep) {
    final String? valueRep = keyValueStore.getString(accessKey);
    if (valueRep == null) {
      initIfNotExist();
      return _getSharedPreferenceValue<T>(
          initIfNotExist, accessKey, convertRep);
    }
    return convertRep(valueRep);
  }

  Key getEncryptionKey() {
    return _getSharedPreferenceValue<Key>(
        _initEncryptionKey, KeyStorage.prefKeyForKey, Key.fromBase64);
  }

  IV getIV() {
    return _getSharedPreferenceValue(
        _initEncryptionIV, KeyStorage.pefKeyForIV, IV.fromBase64);
  }
}
