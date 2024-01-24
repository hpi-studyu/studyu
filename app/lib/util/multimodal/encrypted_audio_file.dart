import 'package:audioplayers/audioplayers.dart';
import 'package:studyu_app/util/multimodal/persistent_storage_handler.dart';

class EncryptedAudioFile {
  late final AudioPlayer _audioPlayer;
  final String _encryptedAudioFilePath;
  late String _temporaryUnencryptedFilePath;
  final PersistentStorageHandler _storageHandler;
  late void Function(bool) _playStateUpdater;

  EncryptedAudioFile(PersistentStorageHandler aStorageHandler, String anEncryptedAudioFilePath)
      : _encryptedAudioFilePath = anEncryptedAudioFilePath,
        _storageHandler = aStorageHandler;

  void preparePlay(Function(bool) aPlayStateUpdater) {
    _audioPlayer = AudioPlayer();
    _playStateUpdater = aPlayStateUpdater;
    _audioPlayer.onPlayerComplete.listen((event) {
      stop();
    });
  }

  Future<void> play() async {
    _temporaryUnencryptedFilePath = await _storageHandler.provideUnencryptedAudio(_encryptedAudioFilePath);
    _playStateUpdater(true);
    _audioPlayer.play(DeviceFileSource(_temporaryUnencryptedFilePath));
  }

  Future<void> stop() async {
    _playStateUpdater(false);
    await _storageHandler.deleteFileByPath(_temporaryUnencryptedFilePath);
    _audioPlayer.dispose();
  }

  void delete() {
    _storageHandler.deleteFileByPath(_encryptedAudioFilePath);
  }
}
