import 'package:flutter/foundation.dart';

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
  });

  factory SpeechControllerState.initial({required bool supported}) {
    return SpeechControllerState(
      status: supported
          ? SpeechLifecycleStatus.idle
          : SpeechLifecycleStatus.unavailable,
    );
  }

  final SpeechLifecycleStatus status;
  final SpeechError? error;
  final String? partialTranscript;

  SpeechControllerState copyWith({
    SpeechLifecycleStatus? status,
    SpeechError? error,
    bool clearError = false,
    String? partialTranscript,
    bool clearTranscript = false,
  }) {
    return SpeechControllerState(
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
      partialTranscript: clearTranscript
          ? null
          : partialTranscript ?? this.partialTranscript,
    );
  }
}
