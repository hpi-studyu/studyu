import 'package:flutter/foundation.dart';

import 'package:studyu_app/services/speech/speech_to_text_language.dart';

typedef SpeechTranscriptCommit = void Function(String textSegment);

enum SpeechLifecycleStatus {
  unavailable,
  idle,
  preparing,
  ready,
  listening,
  error,
}

enum SpeechErrorType { microphonePermission, general }

@immutable
class SpeechError {
  const SpeechError(this.type, {this.details});

  final SpeechErrorType type;
  final String? details;
}

@immutable
class SpeechControllerState {
  const SpeechControllerState({
    required this.status,
    this.error,
    this.partialTranscript,
    required this.language,
  });

  factory SpeechControllerState.initial({
    required SpeechRecognitionLanguage language,
    required bool supported,
  }) {
    return SpeechControllerState(
      status: supported
          ? SpeechLifecycleStatus.idle
          : SpeechLifecycleStatus.unavailable,
      language: language,
    );
  }

  final SpeechLifecycleStatus status;
  final SpeechError? error;
  final String? partialTranscript;
  final SpeechRecognitionLanguage language;

  SpeechControllerState copyWith({
    SpeechLifecycleStatus? status,
    SpeechError? error,
    bool clearError = false,
    String? partialTranscript,
    bool clearTranscript = false,
    SpeechRecognitionLanguage? language,
  }) {
    return SpeechControllerState(
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
      partialTranscript: clearTranscript
          ? null
          : partialTranscript ?? this.partialTranscript,
      language: language ?? this.language,
    );
  }
}
