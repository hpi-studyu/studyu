import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:studyu_app/util/multimodal/persistent_storage_handler.dart';

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
  late PersistentStorageHandler _storageHandler;
  late Function _storeFinalizer;
  PermissionStatus _recordingPermission = PermissionStatus.denied;

  _requestPermission() async {
    PermissionStatus permission = await Permission.microphone.request();
    setState(() {
      _recordingPermission = permission;
    });
  }

  _RecordAudioScreenState() : _audioRecorder = AudioRecorder() {
    _audioRecorder.onStateChanged().listen((event) async {
      if (event == RecordState.stop || event == RecordState.pause) {
        BuildContext? dialogContext;
        // todo create scaffold template for multimodal screens for shared loading animation, feedback, and error handling
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            dialogContext = context;
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.storing_audio),
                  ],
                ),
              ),
            );
          },
        );
        _storeFinalizer((String aPath) {
          Navigator.pop(dialogContext!);
          Navigator.pop(context, aPath);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermission();
    });
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.recording_error),
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.recording_error),
        ),
      );
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
      body: Center(
        child: _recordingPermission.isGranted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _isRecording
                      ? LoadingAnimationWidget.staggeredDotsWave(color: const Color(0xFFEA3799), size: 200)
                      : Container(),
                  ElevatedButton(
                    onPressed: _toggleRecording,
                    child: Text(_isRecording
                        ? AppLocalizations.of(context)!.stop_recording
                        : AppLocalizations.of(context)!.start_recording),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
