import 'package:flutter/material.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';

class AppLanguage extends ChangeNotifier {
  static const String keyLanguageCode = 'language_code';
  final List<Locale> supportedLocales;
  Locale? _appLocale;

  AppLanguage(this.supportedLocales) : super() {
    fetchLocale();
  }

  Locale? get appLocal => _appLocale;

  Future<void> fetchLocale() async {
    final languageCode = await SecureStorage.read('language_code');
    _appLocale = languageCode != null ? Locale(languageCode) : null;
    notifyListeners();
  }

  Future<void> changeLanguage(Locale? locale) async {
    if (_appLocale == locale) return;
    if (locale == null || !supportedLocales.contains(locale)) {
      _appLocale = null;
      await SecureStorage.delete(keyLanguageCode);
    } else {
      _appLocale = locale;
      await SecureStorage.write(keyLanguageCode, locale.languageCode);
    }
    notifyListeners();
  }
}
