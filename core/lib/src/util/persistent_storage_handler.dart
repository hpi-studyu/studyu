import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:studyu_core/src/util/encrypted_audio_file.dart';
import 'package:studyu_core/src/util/encrypter_handler.dart';

class PersistentStorageHandler {
  static const String _encryptedBaseNamePrefix = 'encrypted';
  static const String _stagingBaseNamePrefix = 'staging';
  static const String _encryptedImageFileType = '.encryptedjpg';
  static const String _encryptedAudioFileType = '.encryptedm4a';
  static const String _nonEncryptedAudioFileType = ".m4a";

  late Directory _applicationBaseDirectory;
  late Directory _applicationMediaDirectory;
  late Future<void> _applicationDirectoryFuture;
  late EncrypterHandler _encrypterHandler;
  late Future<void> _encrypterHandlerFuture;

  static bool _isNotEncrypted(FileSystemEntity anEntity) {
    return !path
        .basename(anEntity.path)
        .startsWith(PersistentStorageHandler._encryptedBaseNamePrefix);
  }

  static bool _isFile(FileSystemEntity anEntity) {
    return FileSystemEntity.isFileSync(anEntity.path);
  }

  static int _defaultFileListCompare(FileSystemEntity a, FileSystemEntity b) {
    return a.path.compareTo(b.path);
  }

  // a file name does not include the file suffix/type, like .png
  static String buildFileName(String participantID, String studyID) {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return "${participantID}-${studyID}-${timestamp.toString()}";
  }

  PersistentStorageHandler() {
    _applicationDirectoryFuture = _initializeRawDirectoryHandler();
    _encrypterHandlerFuture = _initializeEncrypterHandler();
  }

  Future<void> _initializeRawDirectoryHandler() async {
    _applicationBaseDirectory = await getApplicationDocumentsDirectory();
    _applicationMediaDirectory =
        Directory("${_applicationBaseDirectory.path}/multimodal-artifacts");
  }

  Future<void> _initializeEncrypterHandler() async {
    _encrypterHandler = await EncrypterHandler.buildHandler();
  }

  Future<void> _deleteAllUnencryptedFileSystemEntities() async {
    await _applicationDirectoryFuture;
    final List<FileSystemEntity> unencryptedEntities =
        _applicationMediaDirectory
            .listSync(followLinks: false)
            .where(PersistentStorageHandler._isNotEncrypted)
            .toList();
    for (final FileSystemEntity unencryptedEntity in unencryptedEntities) {
      unencryptedEntity.deleteSync(recursive: true);
    }
  }

  Future<void> storeImage(XFile image,
      {void Function(String)? pathCallback}) async {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    await _applicationDirectoryFuture;
    await _encrypterHandlerFuture;
    final Uint8List imageByteContent = await image.readAsBytes();
    final Uint8List encryptedImageByteContent =
        _encrypterHandler.encryptFile(imageByteContent);

    final String fileName = [
      PersistentStorageHandler._encryptedBaseNamePrefix,
      timestamp.toString(),
      PersistentStorageHandler._encryptedImageFileType
    ].join();

    final String targetPath =
        path.join(_applicationMediaDirectory.path, fileName);

    await File(targetPath).writeAsBytes(encryptedImageByteContent);
    /*
      The camera package writes back the captured images directly after
      capturing them. The save method only duplicates them to another location.
      Thus, to ensure data privacy as designed, it is required to delete all
      data not explicitly encrypted.
     */
    _deleteAllUnencryptedFileSystemEntities();
    if (pathCallback != null) {
      pathCallback(targetPath);
    }
  }

  Future<void> _finalizeStoreAudio(String aStagingPath) async {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final File unencryptedAudio = File(aStagingPath);
    await _applicationDirectoryFuture;
    await _encrypterHandlerFuture;
    final Uint8List audioByteContent = await unencryptedAudio.readAsBytes();
    final Uint8List encryptedImageByteContent =
        _encrypterHandler.encryptFile(audioByteContent);
    await File(path.join(
            _applicationMediaDirectory.path,
            [
              PersistentStorageHandler._encryptedBaseNamePrefix,
              timestamp.toString(),
              PersistentStorageHandler._encryptedAudioFileType
            ].join()))
        .writeAsBytes(encryptedImageByteContent);
    /*
      The recorder package writes back the captured audio directly after
      capturing them. The save method only duplicates them to another location.
      Thus, to ensure data privacy as designed, it is required to delete all
      data not explicitly encrypted.
     */
    _deleteAllUnencryptedFileSystemEntities();
    return;
  }

  (String, Function) storeAudio() {
    final String stagingPath = _getStagingAudioFilePath();
    void finalize() => _finalizeStoreAudio(stagingPath);
    return (stagingPath, finalize);
  }

  String _getStagingAudioFilePath() {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(
        _applicationMediaDirectory.path,
        [
          PersistentStorageHandler._stagingBaseNamePrefix,
          timestamp.toString(),
          PersistentStorageHandler._nonEncryptedAudioFileType
        ].join());
  }

  Future<List<Uint8List>> getSortedListOfImages() async {
    final List<FileSystemEntity> allFiles = await _getListOfFiles();
    allFiles.sort(PersistentStorageHandler._defaultFileListCompare);
    return allFiles.reversed
        .where((FileSystemEntity anEntity) => anEntity.path
            .contains(PersistentStorageHandler._encryptedImageFileType))
        // FileSystemEntity is the superclass of File
        .map((FileSystemEntity anEntity) => anEntity as File)
        .map((File aFile) => aFile.readAsBytesSync())
        .map(
            (Uint8List aByteArray) => _encrypterHandler.decryptFile(aByteArray))
        .toList();
  }

  Future<String> provideUnencryptedAudio(String anEncryptedAudioPath) async {
    final Uint8List encryptedByteArray =
        File(anEncryptedAudioPath).readAsBytesSync();
    final Uint8List decryptedByteArray =
        _encrypterHandler.decryptFile(encryptedByteArray);
    final String temporaryPath = path.join(
        _applicationMediaDirectory.path,
        [
          PersistentStorageHandler._stagingBaseNamePrefix,
          "ActualPlaying",
          PersistentStorageHandler._nonEncryptedAudioFileType
        ].join());
    await File(temporaryPath).writeAsBytes(decryptedByteArray);
    return temporaryPath;
  }

  Future<List<EncryptedAudioFile>> getSortedListOfEncryptedAudioFiles() async {
    final List<FileSystemEntity> allFiles = await _getListOfFiles();
    allFiles.sort(PersistentStorageHandler._defaultFileListCompare);
    return allFiles.reversed
        .where((FileSystemEntity anEntity) => anEntity.path
            .contains(PersistentStorageHandler._encryptedAudioFileType))
        .map((FileSystemEntity anEntity) => anEntity.path)
        .map((String aPath) => EncryptedAudioFile(this, aPath))
        .toList();
  }

  Future<List<FileSystemEntity>> _getListOfFiles() async {
    await _applicationDirectoryFuture;
    return _applicationMediaDirectory
        .listSync(followLinks: false)
        .where(PersistentStorageHandler._isFile)
        .toList();
  }

  void deleteFile(FileSystemEntity file) {
    if (!PersistentStorageHandler._isFile(file)) {
      return;
    }
    file.deleteSync(recursive: true);
  }

  Future<void> deleteAllFiles() async {
    final List<FileSystemEntity> files = await _getListOfFiles();
    for (final FileSystemEntity file in files) {
      deleteFile(file);
    }
  }

  Future<void> deleteFileByPath(String aPath) async {
    deleteFile(File(aPath));
  }
}
