import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:studyu_core/core.dart';
import 'encrypted_audio_file.dart';
import 'encrypter_handler.dart';

class PersistentStorageHandler {
  static const String _encryptedBaseNamePrefix = 'encrypted_';
  static const String _stagingBaseNamePrefix = 'staging';
  static const String _encryptedImageFileType = '.encryptedjpg';
  static const String _encryptedAudioFileType = '.encryptedm4a';
  static const String _nonEncryptedAudioFileType = ".m4a";
  static const String _nonEncryptedImageFileType = ".jpg";

  final Future<Directory> _applicationMediaDirectory;
  final BlobStorageHandler _blobStorageHandler;
  final EncrypterHandler _encrypterHandler;

  final String _userId;
  final String _studyId;

  PersistentStorageHandler(this._studyId, this._userId)
      : _blobStorageHandler = BlobStorageHandler(),
        _encrypterHandler = EncrypterHandler(),
        _applicationMediaDirectory = _initializeRawDirectoryHandler();

  static bool _isNotEncrypted(FileSystemEntity anEntity) {
    return !path.basename(anEntity.path).startsWith(PersistentStorageHandler._encryptedBaseNamePrefix);
  }

  static bool _isFile(FileSystemEntity anEntity) {
    return FileSystemEntity.isFileSync(anEntity.path);
  }

  static int _defaultFileListCompare(FileSystemEntity a, FileSystemEntity b) {
    return a.path.compareTo(b.path);
  }

  // a file name does not include the file suffix/type, like .png
  String _buildFileName() {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return "user-id_${_userId}_study-id_${_studyId}_$timestamp";
  }

  static Future<Directory> _initializeRawDirectoryHandler() async {
    final Directory applicationBaseDirectory = await getApplicationDocumentsDirectory();
    final applicationMediaDirectory = Directory("${applicationBaseDirectory.path}/multimodal-artifacts");
    if (!applicationMediaDirectory.existsSync()) {
      applicationMediaDirectory.createSync();
    }
    return applicationMediaDirectory;
  }

  Future<void> _deleteAllUnencryptedFileSystemEntities() async {
    final List<FileSystemEntity> unencryptedEntities = (await _applicationMediaDirectory)
        .listSync(followLinks: false)
        .where(PersistentStorageHandler._isNotEncrypted)
        .toList();
    for (final FileSystemEntity unencryptedEntity in unencryptedEntities) {
      unencryptedEntity.deleteSync(recursive: true);
    }
  }

  /// Stores the image in the local file system and uploads it to the blob storage.
  /// Returns the name of the uploaded file.
  Future<String> storeImage(XFile image) async {
    final File temporaryImageFile = File(image.path);
    final Uint8List imageByteContent = await image.readAsBytes();
    final Uint8List encryptedImageByteContent = await _encrypterHandler.encryptFile(imageByteContent);

    final String fileName = _buildFileName();

    final String encryptedFileName = [
      PersistentStorageHandler._encryptedBaseNamePrefix,
      fileName,
      PersistentStorageHandler._encryptedImageFileType,
    ].join();

    final String uploadFileName = [fileName, PersistentStorageHandler._nonEncryptedImageFileType].join();

    await _blobStorageHandler.uploadObservation(
      uploadFileName,
      temporaryImageFile,
    );

    await temporaryImageFile.delete();

    final String localTargetPath = path.join((await _applicationMediaDirectory).path, encryptedFileName);
    final File encryptedFile = File(localTargetPath);
    await encryptedFile.writeAsBytes(encryptedImageByteContent);
    /*
      The camera package writes back the captured images directly after
      capturing them. The save method only duplicates them to another location.
      Thus, to ensure data privacy as designed, it is required to delete all
      data not explicitly encrypted.
     */
    _deleteAllUnencryptedFileSystemEntities();
    return uploadFileName;
  }

  Future<void> _finalizeStoreAudio(
    String aStagingPath,
    void Function(String)? pathCallback,
  ) async {
    final File unencryptedAudio = File(aStagingPath);
    final String fileName = _buildFileName();
    final String encryptedFileName = [
      PersistentStorageHandler._encryptedBaseNamePrefix,
      fileName,
      PersistentStorageHandler._encryptedAudioFileType,
    ].join();
    final String uploadFileName = [fileName, PersistentStorageHandler._nonEncryptedAudioFileType].join();
    await _blobStorageHandler.uploadObservation(
      uploadFileName,
      File(aStagingPath),
    );
    final Uint8List audioByteContent = await unencryptedAudio.readAsBytes();
    final Uint8List encryptedImageByteContent = await _encrypterHandler.encryptFile(audioByteContent);
    final String localTargetPath = path.join((await _applicationMediaDirectory).path, encryptedFileName);
    await File(
      localTargetPath,
    ).writeAsBytes(encryptedImageByteContent);
    /*
      The recorder package writes back the captured audio directly after
      capturing them. The save method only duplicates them to another location.
      Thus, to ensure data privacy as designed, it is required to delete all
      data not explicitly encrypted.
     */
    _deleteAllUnencryptedFileSystemEntities();
    if (pathCallback != null) {
      pathCallback(uploadFileName);
    }
    return;
  }

  Future<(String, Function)> storeAudio() async {
    final String stagingPath = await _getStagingAudioFilePath();
    void finalize(void Function(String)? pathCallback) => _finalizeStoreAudio(stagingPath, pathCallback);
    return (stagingPath, finalize);
  }

  Future<String> _getStagingAudioFilePath() async {
    final fileName = _buildFileName();
    return path.join(
      (await _applicationMediaDirectory).path,
      [
        PersistentStorageHandler._stagingBaseNamePrefix,
        fileName,
        PersistentStorageHandler._nonEncryptedAudioFileType,
      ].join(),
    );
  }

  Future<List<Uint8List>> getSortedListOfImages() async {
    final List<FileSystemEntity> allFiles = await _getListOfFiles();
    allFiles.sort(PersistentStorageHandler._defaultFileListCompare);
    final decryptedFiles = allFiles.reversed
        .where(
          (FileSystemEntity anEntity) => anEntity.path.contains(PersistentStorageHandler._encryptedImageFileType),
        )
        // FileSystemEntity is the superclass of File
        .map((FileSystemEntity anEntity) => anEntity as File)
        .map((File aFile) => aFile.readAsBytesSync())
        .map(
          (Uint8List aByteArray) => _encrypterHandler.decryptFile(aByteArray),
        )
        .toList();
    return Future.wait(decryptedFiles);
  }

  Future<String> provideUnencryptedAudio(String anEncryptedAudioPath) async {
    final Uint8List encryptedByteArray = File(anEncryptedAudioPath).readAsBytesSync();
    final Uint8List decryptedByteArray = await _encrypterHandler.decryptFile(encryptedByteArray);
    final mediaDirectory = await _applicationMediaDirectory;
    final String temporaryPath = path.join(
      mediaDirectory.path,
      [
        PersistentStorageHandler._stagingBaseNamePrefix,
        "ActualPlaying",
        PersistentStorageHandler._nonEncryptedAudioFileType,
      ].join(),
    );
    await File(temporaryPath).writeAsBytes(decryptedByteArray);
    return temporaryPath;
  }

  Future<List<EncryptedAudioFile>> getSortedListOfEncryptedAudioFiles() async {
    final List<FileSystemEntity> allFiles = await _getListOfFiles();
    allFiles.sort(PersistentStorageHandler._defaultFileListCompare);
    return allFiles.reversed
        .where(
          (FileSystemEntity anEntity) => anEntity.path.contains(PersistentStorageHandler._encryptedAudioFileType),
        )
        .map((FileSystemEntity anEntity) => anEntity.path)
        .map((String aPath) => EncryptedAudioFile(this, aPath))
        .toList();
  }

  Future<List<FileSystemEntity>> _getListOfFiles() async {
    return (await _applicationMediaDirectory)
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
