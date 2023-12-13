import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../util/multimodal/persistent_storage_handler.dart';

class RecordAudioScreen extends StatefulWidget {
  final String userId;
  final String studyId;

  const RecordAudioScreen({super.key, required this.userId, required this.studyId});

  @override
  State<RecordAudioScreen> createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen> {
  final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  late Future<void> _initializeRecorderPermissionsFuture;
  late PersistentStorageHandler _storageHandler;
  late Function _storeFinalizer;

  Future<void> _initializeAudioRecorderPermissions() async {
    await Permission.microphone.request();
  }

  _RecordAudioScreenState() : _audioRecorder = AudioRecorder() {
    _audioRecorder.onStateChanged().listen((event) async {
      if (event == RecordState.stop || event == RecordState.pause) {
        _storeFinalizer((String aPath) => Navigator.pop(context, aPath));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeRecorderPermissionsFuture = _initializeAudioRecorderPermissions();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      _storageHandler = PersistentStorageHandler(widget.userId, widget.studyId);
      var (stagingPath, finalizer) = await _storageHandler.storeAudio();
      _storeFinalizer = finalizer;
      await _audioRecorder.start(const RecordConfig(), path: stagingPath);
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print(AppLocalizations.of(context)!.error_recording + ": $e");
      }
    }
  }

  Future<void> _toggleRecording() async {
    _isRecording ? _stopRecording() : _startRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
      ),
      body: FutureBuilder<void>(
        future: _initializeRecorderPermissionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _isRecording
                      ? LoadingAnimationWidget.staggeredDotsWave(color: const Color(0xFFEA3799), size: 200)
                      : Container(),
                  ElevatedButton(
                    onPressed: _toggleRecording,
                    child: Text(_isRecording ? AppLocalizations.of(context)!.stop_recording : AppLocalizations.of(context)!.start_recording),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
