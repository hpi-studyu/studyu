import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:studyu_app/services/speech/speech_controller_models.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SpeechToTextController extends ValueNotifier<SpeechControllerState> {
  SpeechToTextController({
    required this.onFinalTranscription,
    String? serverUrl,
  }) : _serverUrl = serverUrl ?? env.sttWebSocketUrl ?? '',
       _audioRecorder = AudioRecorder(),
       super(
         SpeechControllerState.initial(
           supported:
               _platformSupported &&
               (serverUrl ?? env.sttWebSocketUrl ?? '').isNotEmpty,
         ),
       ) {
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

  /// Delay before attempting to reconnect after connection loss.
  /// This prevents rapid reconnection attempts and gives the server/network
  /// time to stabilize. 500ms provides a good balance between responsiveness
  /// and avoiding connection spam.
  static const int _reconnectionDelayMs = 500;

  /// Delay after sending EOF to allow server to process and send final results.
  /// Vosk server needs time to finalize transcription after receiving EOF.
  /// 300ms is typically sufficient for the server to send remaining data.
  static const int _eofWaitDelayMs = 300;

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
    } catch (e) {
      return false;
    }
  }

  Future<bool> startListening() async {
    if (!_platformSupported) {
      _emitError(SpeechErrorType.general);
      return false;
    }

    if (_serverUrl.isEmpty) {
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

      _isListening = true;
      await _startWebSocketConnection();
      await _startAudioRecording();

      value = value.copyWith(
        status: SpeechLifecycleStatus.listening,
        clearError: true,
      );

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
      final token = Supabase.instance.client.auth.currentSession?.accessToken;

      final ws = await WebSocket.connect(
        _serverUrl,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      _wsChannel = IOWebSocketChannel(ws);

      final config = {
        'config': {'sample_rate': _sampleRate},
      };
      _wsChannel!.sink.add(jsonEncode(config));
      _wsChannel!.stream.listen(
        (data) {
          if (_isDisposed) return;
          try {
            final result = jsonDecode(data as String) as Map<String, dynamic>;
            _handleTranscriptionResult(result);
          } catch (e) {
            debugPrint('Failed to parse WebSocket data: $e');
          }
        },
        onError: (error) {
          if (_isDisposed) return;

          _handleConnectionLoss();
        },
        onDone: () {
          if (_isDisposed) return;

          _handleConnectionLoss();
        },
        cancelOnError: false,
      );
    } catch (e) {
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  void _handleConnectionLoss() {
    // Atomic check-and-set to prevent race condition
    if (_isListening && !_isReconnecting) {
      _isReconnecting = true;
      _reconnect();
    }
  }

  Future<void> _reconnect() async {
    // Double-check in case of edge cases
    if (_isDisposed) {
      _isReconnecting = false;
      return;
    }

    try {
      // Close existing connection if any
      try {
        await _wsChannel?.sink.close();
      } catch (e) {
        debugPrint(
          '[SpeechToText] Error closing WebSocket during reconnect: $e',
        );
      }
      _wsChannel = null;

      // Wait a bit before reconnecting
      await Future.delayed(const Duration(milliseconds: _reconnectionDelayMs));

      if (!_isListening) {
        _isReconnecting = false;
        return;
      }

      await _startWebSocketConnection();
    } catch (e) {
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
      // Stop audio recording
      await _audioStreamSubscription?.cancel();
      await _audioRecorder.stop();

      // Send EOF to WebSocket
      if (_wsChannel != null) {
        try {
          _wsChannel!.sink.add(jsonEncode({'eof': 1}));
          // Give server a moment to send final results
          await Future.delayed(const Duration(milliseconds: _eofWaitDelayMs));
          await _wsChannel!.sink.close();
        } catch (e) {
          // Errors during closing are expected if connection is already dead
          debugPrint(
            '[SpeechToText] Error during graceful WebSocket close: $e',
          );
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
    _isListening = false;
    try {
      await _audioStreamSubscription?.cancel();
      await _audioRecorder.stop();
      if (_wsChannel != null) {
        await _wsChannel!.sink.close();
        _wsChannel = null;
      }
    } catch (e) {
      debugPrint('[SpeechToText] Error during force reset cleanup: $e');
    }
    value = value.copyWith(
      status: SpeechLifecycleStatus.idle,
      clearTranscript: true,
    );
  }

  void _commitTranscript() {
    final transcript = _latestTranscript;
    if (transcript != null && transcript.isNotEmpty) {
      onFinalTranscription(transcript);
    }
  }

  void _emitError(
    SpeechErrorType type, {
    String? details,
    StackTrace? stackTrace,
  }) {
    _isListening = false;
    _latestTranscript = null;

    try {
      _audioStreamSubscription?.cancel();
      _audioRecorder.stop();
    } catch (e) {
      debugPrint(
        '[SpeechToText] Error stopping audio during error emission: $e',
      );
    }

    value = value.copyWith(
      status: SpeechLifecycleStatus.error,
      error: SpeechError(type, details: details),
      clearTranscript: true,
    );
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    try {
      await _audioStreamSubscription?.cancel();
      await _audioRecorder.stop();
      await _audioRecorder.dispose();
      await _wsChannel?.sink.close();
    } catch (e) {
      debugPrint('[SpeechToText] Error during dispose cleanup: $e');
    }
    super.dispose();
  }
}
