import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'key_storage.dart';

class EncrypterHandler {
  static Future<Encrypter> _buildEncrypter(EncrypterHandler handler) async {
    return Encrypter(AES(await handler._keyStorage.getEncryptionKey()));
  }

  final KeyStorage _keyStorage;

  EncrypterHandler() : _keyStorage = KeyStorage();

  Future<String> encryptText(String aText) async {
    final Encrypter encrypter = await _buildEncrypter(this);
    return encrypter.encrypt(aText, iv: await _keyStorage.getIV()).base64;
  }

  Future<String> decryptText(String anEncryptedText) async {
    final Encrypter encrypter = await _buildEncrypter(this);
    return encrypter.decrypt(
      Encrypted.fromBase64(anEncryptedText),
      iv: await _keyStorage.getIV(),
    );
  }

  Future<Uint8List> encryptFile(Uint8List aFileContent) async {
    final Encrypter encrypter = await _buildEncrypter(this);
    return encrypter.encryptBytes(aFileContent, iv: await _keyStorage.getIV()).bytes;
  }

  Future<Uint8List> decryptFile(Uint8List anEncryptedFileContent) async {
    final Encrypter encrypter = await _buildEncrypter(this);
    return Uint8List.fromList(
      encrypter.decryptBytes(
        Encrypted(anEncryptedFileContent),
        iv: await _keyStorage.getIV(),
      ),
    );
  }
}
