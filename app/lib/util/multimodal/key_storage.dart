import 'package:encrypt/encrypt.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class KeyStorage {
  static const String prefKeyForKey = "StudyU_MediaEncryptionKey";
  static const String pefKeyForIV = "StudyU_MediaEncryptionIV";

  void _initEncryptionKey() {
    final Key key = Key.fromSecureRandom(32);
    SecureStorage.write(KeyStorage.prefKeyForKey, key.base64);
  }

  void _initEncryptionIV() {
    final IV iv = IV.fromSecureRandom(16);
    SecureStorage.write(KeyStorage.pefKeyForIV, iv.base64);
  }

  Future<T> _getStorageValue<T>(
    void Function() initIfNotExist,
    String accessKey,
    T Function(String) convertRep,
  ) async {
    final String? valueRep = await SecureStorage.read(accessKey);
    if (valueRep == null) {
      initIfNotExist();
      return await _getStorageValue<T>(
        initIfNotExist,
        accessKey,
        convertRep,
      );
    }

    return convertRep(valueRep);
  }

  Future<Key> getEncryptionKey() {
    return _getStorageValue<Key>(
      _initEncryptionKey,
      KeyStorage.prefKeyForKey,
      Key.fromBase64,
    );
  }

  Future<IV> getIV() {
    return _getStorageValue<IV>(
      _initEncryptionIV,
      KeyStorage.pefKeyForIV,
      IV.fromBase64,
    );
  }
}
