import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  static const String keyLanguageCode = 'language_code';
  final List<Locale> supportedLocales;
  Locale? _appLocale;

  AppLanguage(this.supportedLocales) : super() {
    fetchLocale();
  }

  Locale? get appLocal => _appLocale;

  Future<void> fetchLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');
    _appLocale = languageCode != null ? Locale(languageCode) : null;
  }

  Future<void> changeLanguage(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (_appLocale == locale) return;
    if (locale == null || !supportedLocales.contains(locale)) {
      _appLocale = null;
      await prefs.remove(keyLanguageCode);
    } else {
      _appLocale = locale;
      await prefs.setString(keyLanguageCode, locale.languageCode);
    }
    notifyListeners();
  }
}
