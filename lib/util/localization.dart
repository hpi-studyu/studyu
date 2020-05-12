import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Nof1Localizations {
  final Locale locale;

  Nof1Localizations(this.locale);

  static Nof1Localizations of(BuildContext context) {
    return Localizations.of<Nof1Localizations>(context, Nof1Localizations);
  }

  static const LocalizationsDelegate<Nof1Localizations> delegate =
  _Nof1LocalizationsDelegate();

  Map<String, String> _localizedStrings;

  Future<bool> load() async {
    var jsonString = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key];
  }
}

class _Nof1LocalizationsDelegate
    extends LocalizationsDelegate<Nof1Localizations> {
  const _Nof1LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<Nof1Localizations> load(Locale locale) async {
    var localizations = Nof1Localizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_Nof1LocalizationsDelegate old) => false;
}