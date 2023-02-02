// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'platform_locale_interface.dart';

class PlatformLocaleWeb implements PlatformLocale {
  @override
  Locale getPlatformLocale() {
    var platformLocaleName = html.window.navigator.language;
    print("Platform Locale Name (WEB): $platformLocaleName");

    // Language code only
    if (platformLocaleName.length == 2) {
      return Locale.fromSubtags(languageCode: platformLocaleName);
    }

    // Language and country codes
    String languageCode = platformLocaleName.substring(0, platformLocaleName.indexOf('-'));
    String countryCode = platformLocaleName.substring(platformLocaleName.indexOf('-') + 1);

    return Locale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
    );
  }
}

PlatformLocale getImplementation() => PlatformLocaleWeb();
