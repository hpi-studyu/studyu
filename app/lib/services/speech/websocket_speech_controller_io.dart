import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:studyu_app/services/speech/speech_controller_models.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SpeechToTextController extends ValueNotifier<SpeechControllerState> {
  SpeechToTextController({
    required this.onFinalTranscription,
    String? serverUrl,
  }) : _serverUrl = serverUrl ?? 'wss://stt.ibrahimozkan.dev',
       _audioRecorder = AudioRecorder(),
       super(SpeechControllerState.initial(supported: _platformSupported)) {
    _ensureInitialized();
  }

  final SpeechTranscriptCommit onFinalTranscription;
  final AudioRecorder _audioRecorder;
  final String _serverUrl;

  String? _latestTranscript;
  bool _isDisposed = false;
  Future<bool>? _initialization;
  WebSocketChannel? _wsChannel;
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  bool _isListening = false;
  bool _isReconnecting = false;

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

  Future<bool> startListening() async {
    debugPrint('[WebSocketSpeech] startListening requested');
    if (!_platformSupported) {
      _emitError(SpeechErrorType.general);
      return false;
    }
    if (value.status == SpeechLifecycleStatus.listening ||
        value.status == SpeechLifecycleStatus.preparing) {
      debugPrint('[WebSocketSpeech] Already listening or preparing');
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

      _isListening = true;
      await _startWebSocketConnection();
      await _startAudioRecording();

      value = value.copyWith(
        status: SpeechLifecycleStatus.listening,
        clearError: true,
      );
      debugPrint('[WebSocketSpeech] Listening started successfully');

      return true;
    } catch (e, stack) {
      _isListening = false;
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
      debugPrint('[WebSocketSpeech] Connecting to $_serverUrl...');
      _wsChannel = IOWebSocketChannel.connect(Uri.parse(_serverUrl));

      // Send configuration with sample rate
      final config = {
        'config': {'sample_rate': _sampleRate},
      };
      _wsChannel!.sink.add(jsonEncode(config));
      debugPrint('[WebSocketSpeech] WebSocket connected, config sent');

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
          debugPrint('[WebSocketSpeech] WebSocket error: $error');
          _handleConnectionLoss();
        },
        onDone: () {
          if (_isDisposed) return;
          debugPrint('[WebSocketSpeech] WebSocket closed by server');
          _handleConnectionLoss();
        },
        cancelOnError: false,
      );
    } catch (e) {
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  void _handleConnectionLoss() {
    debugPrint(
      '[WebSocketSpeech] Connection loss detected. Listening: $_isListening, Reconnecting: $_isReconnecting',
    );
    if (_isListening && !_isReconnecting) {
      _reconnect();
    }
  }

  Future<void> _reconnect() async {
    if (_isReconnecting || _isDisposed) return;
    _isReconnecting = true;
    debugPrint('[WebSocketSpeech] Attempting to reconnect...');

    try {
      // Close existing connection if any
      try {
        await _wsChannel?.sink.close();
      } catch (_) {}
      _wsChannel = null;

      // Wait a bit before reconnecting
      await Future.delayed(const Duration(milliseconds: 500));

      if (!_isListening) {
        debugPrint('[WebSocketSpeech] Reconnect aborted: not listening');
        _isReconnecting = false;
        return;
      }

      await _startWebSocketConnection();
      debugPrint('[WebSocketSpeech] Reconnected successfully');
    } catch (e) {
      debugPrint('[WebSocketSpeech] Reconnection failed: $e');
      // If reconnection fails, we might want to stop listening or try again later
      // For now, let's stop to avoid infinite loops if server is down
      _emitError(
        SpeechErrorType.general,
        details: 'Connection lost. Please try again.',
      );
    } finally {
      _isReconnecting = false;
    }
  }

  Future<void> _startAudioRecording() async {
    try {
      debugPrint('[WebSocketSpeech] Starting audio recording...');
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
            try {
              _wsChannel!.sink.add(audioData);
            } catch (e) {
              // If send fails, it might be because connection is closed
              // The onDone/onError of WebSocket should handle this, but just in case
              debugPrint('[WebSocketSpeech] Failed to send audio: $e');
            }
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
      debugPrint('[WebSocketSpeech] Audio recording started');
    } catch (e) {
      throw Exception('Failed to start audio recording: $e');
    }
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
      // debugPrint('[WebSocketSpeech] Partial: $partial'); // Uncomment for very verbose logs
    } else if (text != null) {
      // Final transcription (silence detected or end of phrase)
      final trimmed = text.trim();
      if (trimmed.isNotEmpty) {
        debugPrint('[WebSocketSpeech] Final transcript: $trimmed');
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
    debugPrint('[WebSocketSpeech] stopListening requested');
    if (!_isListening) return;
    _isListening = false;

    try {
      // Stop audio recording
      await _audioStreamSubscription?.cancel();
      await _audioRecorder.stop();
      debugPrint('[WebSocketSpeech] Audio recording stopped');

      // Send EOF to WebSocket
      if (_wsChannel != null) {
        try {
          _wsChannel!.sink.add(jsonEncode({'eof': 1}));
          // Give server a moment to send final results
          await Future.delayed(const Duration(milliseconds: 300));
          await _wsChannel!.sink.close();
          debugPrint('[WebSocketSpeech] WebSocket closed cleanly');
        } catch (_) {
          // Ignore errors during closing
        }
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
    debugPrint('[WebSocketSpeech] forceReset requested');
    _isListening = false;
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

    // Ensure recorder is stopped on error
    try {
      _audioStreamSubscription?.cancel();
      _audioRecorder.stop();
    } catch (_) {}

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
