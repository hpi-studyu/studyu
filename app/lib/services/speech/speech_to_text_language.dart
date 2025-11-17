import 'package:flutter/material.dart';

enum SpeechRecognitionLanguage {
  english(localeCode: 'en', localeId: 'en_US'),
  german(localeCode: 'de', localeId: 'de_DE');

  const SpeechRecognitionLanguage({
    required this.localeCode,
    required this.localeId,
  });

  final String localeCode;
  final String localeId;

  static SpeechRecognitionLanguage fromCode(String? code) {
    if (code == null) return SpeechRecognitionLanguage.english;
    return SpeechRecognitionLanguage.values.firstWhere(
      (lang) => lang.localeCode == code,
      orElse: () => SpeechRecognitionLanguage.english,
    );
  }

  static SpeechRecognitionLanguage fromLocale(Locale? locale) {
    if (locale == null) return SpeechRecognitionLanguage.english;
    switch (locale.languageCode) {
      case 'de':
        return SpeechRecognitionLanguage.german;
      default:
        return SpeechRecognitionLanguage.english;
    }
  }
}
