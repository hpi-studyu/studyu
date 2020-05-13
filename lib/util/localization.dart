import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Nof1Localizations {
  final Locale locale;
  final bool testing;

  Nof1Localizations(this.locale, {this.testing = false});

  static Nof1Localizations of(BuildContext context) {
    return Localizations.of<Nof1Localizations>(context, Nof1Localizations);
  }

  static const LocalizationsDelegate<Nof1Localizations> delegate =
  Nof1LocalizationsDelegate();

  Map<String, String> _localizedStrings;

  Future<Nof1Localizations> load() async {
    var jsonString = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return Nof1Localizations(locale);
  }

  Future<Nof1Localizations> loadTest(Locale locale) async {
    return Nof1Localizations(locale);
  }

  String translate(String key) {
    if (testing) {
      return key;
    }
    return _localizedStrings[key];
  }
}

class Nof1LocalizationsDelegate
    extends LocalizationsDelegate<Nof1Localizations> {
  const Nof1LocalizationsDelegate({this.testing = false});

  final bool testing;

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<Nof1Localizations> load(Locale locale) async {
    var localizations = Nof1Localizations(locale, testing: testing);
    if (testing) {
      await localizations.loadTest(locale);
    } else {
      await localizations.load();
    }
    return localizations;
  }

  @override
  bool shouldReload(Nof1LocalizationsDelegate old) => false;
}