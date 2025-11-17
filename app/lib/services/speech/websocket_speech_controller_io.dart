import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:record/record.dart';
import 'package:studyu_app/services/speech/speech_controller_models.dart';
import 'package:studyu_app/services/speech/speech_to_text_language.dart';
import 'package:studyu_app/services/speech/speech_to_text_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SpeechToTextController extends ValueNotifier<SpeechControllerState> {
  SpeechToTextController({
    required this.onFinalTranscription,
    required BuildContext context,
    SpeechRecognitionLanguage initialLanguage =
        SpeechRecognitionLanguage.english,
    String? serverUrl,
  })  : _language = initialLanguage,
        _serverUrl = serverUrl ?? 'wss://stt.ibrahimozkan.dev',
        // ignore: unused_field
        _context = context,
        _audioRecorder = AudioRecorder(),
        super(
          SpeechControllerState.initial(
            language: initialLanguage,
            supported: _platformSupported,
          ),
        ) {
    _ensureInitialized();
  }

  final SpeechTranscriptCommit onFinalTranscription;
  // ignore: unused_field
  final BuildContext _context;
  final AudioRecorder _audioRecorder;
  final String _serverUrl;

  SpeechRecognitionLanguage _language;
  String? _latestTranscript;
  bool _isDisposed = false;
  Future<bool>? _initialization;
  WebSocketChannel? _wsChannel;
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  Timer? _silenceTimer;
  bool _isListening = false;

  static const int _sampleRate = 16000; // Vosk typically uses 16kHz

  static bool get _platformSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows;
  }

  static bool get isSupportedPlatform => _platformSupported;

  bool get isListening => value.status == SpeechLifecycleStatus.listening;

  SpeechRecognitionLanguage get language => _language;

  Future<bool> _ensureInitialized() {
    _initialization ??= _initializeRecorder();
    return _initialization!;
  }

  Future<bool> _initializeRecorder() async {
    if (!_platformSupported) return false;
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      return hasPermission;
    } catch (e, stack) {
      debugPrint('[WebSocketSpeech] init error: $e');
      debugPrint(stack.toString());
      return false;
    }
  }

  Future<void> updateLanguage(SpeechRecognitionLanguage language) async {
    if (_language == language) return;
    _language = language;
    value = value.copyWith(language: language);
    await SpeechToTextPreferences.setPreferredLanguage(language);
  }

  Future<bool> startListening() async {
    if (!_platformSupported) {
      _emitError(SpeechErrorType.general);
      return false;
    }
    if (value.status == SpeechLifecycleStatus.listening ||
        value.status == SpeechLifecycleStatus.preparing) {
      return false;
    }

    value = value.copyWith(
      status: SpeechLifecycleStatus.preparing,
      clearError: true,
      clearTranscript: true,
    );

    try {
      final available = await _ensureInitialized();
      if (!available) {
        _emitError(SpeechErrorType.microphonePermission);
        return false;
      }

      await _startWebSocketConnection();
      await _startAudioRecording();

      _isListening = true;
      value = value.copyWith(
        status: SpeechLifecycleStatus.listening,
        clearError: true,
      );

      return true;
    } catch (e, stack) {
      _emitError(
        SpeechErrorType.general,
        details: 'Failed to start speech input: $e',
        stackTrace: stack,
      );
      return false;
    }
  }

  Future<void> _startWebSocketConnection() async {
    try {
      _wsChannel = IOWebSocketChannel.connect(
        Uri.parse(_serverUrl),
      );

      // Send configuration with sample rate
      final config = {
        'config': {
          'sample_rate': _sampleRate,
        }
      };
      _wsChannel!.sink.add(jsonEncode(config));

      // Listen for transcription results
      _wsChannel!.stream.listen(
        (data) {
          if (_isDisposed) return;
          try {
            final result = jsonDecode(data as String) as Map<String, dynamic>;
            _handleTranscriptionResult(result);
          } catch (e) {
            debugPrint('[WebSocketSpeech] Error parsing response: $e');
          }
        },
        onError: (error) {
          if (_isDisposed) return;
          _emitError(
            SpeechErrorType.general,
            details: 'WebSocket error: $error',
          );
        },
        onDone: () {
          if (_isDisposed) return;
        },
        cancelOnError: false,
      );
    } catch (e) {
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  Future<void> _startAudioRecording() async {
    try {
      final stream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
      );

      _audioStreamSubscription = stream.listen(
        (audioData) {
          if (_wsChannel != null && !_isDisposed && _isListening) {
            _wsChannel!.sink.add(audioData);
            _resetSilenceTimer();
          }
        },
        onError: (error) {
          if (_isDisposed) return;
          _emitError(
            SpeechErrorType.general,
            details: 'Audio recording error: $error',
          );
        },
        cancelOnError: false,
      );
    } catch (e) {
      throw Exception('Failed to start audio recording: $e');
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    // No automatic stop on silence - user must manually stop
  }

  void _handleTranscriptionResult(Map<String, dynamic> result) {
    if (_isDisposed) return;

    // Vosk server returns partial results and final results
    final text = result['text'] as String?;
    final partial = result['partial'] as String?;

    if (partial != null && partial.isNotEmpty) {
      // Show partial transcription (ongoing speech)
      _latestTranscript = partial.trim();
      value = value.copyWith(partialTranscript: partial);
    } else if (text != null) {
      // Final transcription (silence detected or end of phrase)
      final trimmed = text.trim();
      if (trimmed.isNotEmpty) {
        // Commit the final result
        _latestTranscript = trimmed;
        _commitTranscript();
        // Keep listening - don't clear partial transcript immediately
        // to avoid visual flicker between phrases
      } else {
        // Empty final result - just clear the partial transcript
        value = value.copyWith(clearTranscript: true);
      }
      // Important: Reset to allow new partial results to show
      _latestTranscript = null;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;

    try {
      // Cancel silence timer
      _silenceTimer?.cancel();

      // Stop audio recording
      await _audioStreamSubscription?.cancel();
      await _audioRecorder.stop();

      // Send EOF to WebSocket
      if (_wsChannel != null) {
        _wsChannel!.sink.add(jsonEncode({'eof': 1}));
        // Give server a moment to send final results
        await Future.delayed(const Duration(milliseconds: 300));
        await _wsChannel!.sink.close();
        _wsChannel = null;
      }

      value = value.copyWith(
        status: SpeechLifecycleStatus.ready,
        clearTranscript: true,
      );
    } catch (e, stack) {
      _emitError(
        SpeechErrorType.general,
        details: 'Failed to stop speech input: $e',
        stackTrace: stack,
      );
    }
  }

  Future<void> forceReset() async {
    _isListening = false;
    _silenceTimer?.cancel();
    try {
      await _audioStreamSubscription?.cancel();
      await _audioRecorder.stop();
      if (_wsChannel != null) {
        await _wsChannel!.sink.close();
        _wsChannel = null;
      }
    } catch (_) {}
    value = value.copyWith(
      status: SpeechLifecycleStatus.idle,
      clearTranscript: true,
    );
  }

  void _commitTranscript() {
    final transcript = _latestTranscript;
    if (transcript != null && transcript.isNotEmpty) {
      onFinalTranscription(transcript);
      // Don't clear immediately to avoid flicker - the next partial will replace it
      // or we'll clear it when we get an empty final result
    }
  }

  void _emitError(
    SpeechErrorType type, {
    String? details,
    StackTrace? stackTrace,
  }) {
    _isListening = false;
    _latestTranscript = null;
    debugPrint('[WebSocketSpeech] error=$type details=${details ?? ''}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
    value = value.copyWith(
      status: SpeechLifecycleStatus.error,
      error: SpeechError(type, details: details),
      clearTranscript: true,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _silenceTimer?.cancel();
    try {
      unawaited(_audioStreamSubscription?.cancel());
      unawaited(_audioRecorder.stop());
      unawaited(_audioRecorder.dispose());
      unawaited(_wsChannel?.sink.close());
    } catch (_) {
      // Ignore dispose errors
    }
    super.dispose();
  }
}
