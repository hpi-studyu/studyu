import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:studyu_core/core.dart';

class RecordAudioScreen extends StatefulWidget {
  const RecordAudioScreen({super.key});

  @override
  RecordAudioScreenState createState() => RecordAudioScreenState();
}

class RecordAudioScreenState extends State<RecordAudioScreen> {
  final Record _audioRecorder;
  bool _isRecording = false;
  late Future<void> _initializeRecorderPermissionsFuture;
  // TODO: change mock up values
  final PersistentStorageHandler _storageHandler =
      PersistentStorageHandler("Peter", "WhitenessStudy");
  late Function _storeFinalizer;

  Future<void> _initializeAudioRecorderPermissions() async {
    await Permission.microphone.request();
  }

  RecordAudioScreenState() : _audioRecorder = Record() {
    _audioRecorder.onStateChanged().listen((event) {
      if (event == RecordState.stop || event == RecordState.pause) {
        _storeFinalizer();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeRecorderPermissionsFuture =
        _initializeAudioRecorderPermissions();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      var (stagingPath, finalizer) = _storageHandler.storeAudio();
      _storeFinalizer = finalizer;
      await _audioRecorder.start(path: stagingPath);
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
        print('Recording stop error: $e');
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
                return Column(
                  children: [
                    _isRecording
                        ? LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color(0xFFEA3799), size: 200)
                        : Container(),
                    ElevatedButton(
                      onPressed: _toggleRecording,
                      child: Text(
                          _isRecording ? 'Stop Recording' : 'Start Recording'),
                    )
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}