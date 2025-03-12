import 'dart:js_interop';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/platform_locale/platform_locale_interface.dart';

class PlatformLocaleWeb implements PlatformLocale {
  @JS()
  external JSObject get navigator;
  @JS()
  external String get language;

  @override
  Locale getPlatformLocale() {
    final platformLocaleName = language;
    print("Platform Locale Name (WEB): $platformLocaleName");

    // Language code only
    if (platformLocaleName.length == 2) {
      return Locale.fromSubtags(languageCode: platformLocaleName);
    }

    // Language and country codes
    final String languageCode =
        platformLocaleName.substring(0, platformLocaleName.indexOf('-'));
    final String countryCode =
        platformLocaleName.substring(platformLocaleName.indexOf('-') + 1);

    return Locale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
    );
  }
}

PlatformLocale getImplementation() => PlatformLocaleWeb();
