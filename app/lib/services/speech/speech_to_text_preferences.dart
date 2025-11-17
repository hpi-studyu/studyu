import 'dart:ui';

import 'package:studyu_app/services/speech/speech_to_text_language.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class SpeechToTextPreferences {
  static const _languageKey = 'speech_to_text_language';

  static Future<SpeechRecognitionLanguage> preferredLanguage({
    Locale? fallbackLocale,
  }) async {
    final stored = await SecureStorage.read(_languageKey);
    if (stored != null) return SpeechRecognitionLanguage.fromCode(stored);
    if (fallbackLocale != null) {
      return SpeechRecognitionLanguage.fromLocale(fallbackLocale);
    }
    return SpeechRecognitionLanguage.english;
  }

  static Future<void> setPreferredLanguage(
    SpeechRecognitionLanguage language,
  ) async {
    await SecureStorage.write(_languageKey, language.localeCode);
  }
}
