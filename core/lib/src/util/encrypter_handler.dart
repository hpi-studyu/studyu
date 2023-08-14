import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:studyu_core/src/util/key_storage.dart';

class EncrypterHandler {
  static Encrypter _buildEncrypter(EncrypterHandler handler) {
    return Encrypter(AES(handler._keyStorage.getEncryptionKey()));
  }

  static Future<EncrypterHandler> buildHandler() async {
    final KeyStorage aKeyStorage = await KeyStorage.buildHandler();
    return EncrypterHandler(aKeyStorage);
  }

  final KeyStorage _keyStorage;

  EncrypterHandler(KeyStorage aKeyStorage) : _keyStorage = aKeyStorage;

  String encryptText(String aText) {
    final Encrypter encrypter = _buildEncrypter(this);
    return encrypter.encrypt(aText, iv: _keyStorage.getIV()).base64;
  }

  String decryptText(String anEncryptedText) {
    final Encrypter encrypter = _buildEncrypter(this);
    return encrypter.decrypt(Encrypted.fromBase64(anEncryptedText),
        iv: _keyStorage.getIV());
  }

  Uint8List encryptFile(Uint8List aFileContent) {
    final Encrypter encrypter = _buildEncrypter(this);
    return encrypter.encryptBytes(aFileContent, iv: _keyStorage.getIV()).bytes;
  }

  Uint8List decryptFile(Uint8List anEncryptedFileContent) {
    final Encrypter encrypter = _buildEncrypter(this);
    return Uint8List.fromList(
      encrypter.decryptBytes(Encrypted(anEncryptedFileContent),
          iv: _keyStorage.getIV()),
    );
  }
}
