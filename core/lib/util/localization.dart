import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  final List<Locale> supportedLocales;
  Locale _appLocale;

  AppLanguage(this.supportedLocales) : super() {
    fetchLocale();
  }

  Locale get appLocal => _appLocale;

  Future<void> fetchLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final pref = prefs.getString('language_code');
    _appLocale = pref != null ? Locale(pref) : null;
  }

  Future<void> changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (_appLocale == locale) return;
    if (locale == null || !supportedLocales.contains(locale)) {
      _appLocale = null;
      await prefs.setString('language_code', null);
    } else {
      _appLocale = locale;
      await prefs.setString('language_code', locale.languageCode);
    }
    notifyListeners();
  }
}
