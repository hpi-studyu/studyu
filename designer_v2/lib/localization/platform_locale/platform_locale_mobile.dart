import 'dart:io';
import 'dart:ui';

import 'platform_locale_interface.dart';

class PlatformLocaleMobile implements PlatformLocale {
  @override
  Locale getPlatformLocale() {
    String platformLocaleName = Platform.localeName;
    print("Platform Locale Name (Mobile): $platformLocaleName");

    // Language code only
    if (platformLocaleName.length == 2) {
      return Locale.fromSubtags(languageCode: platformLocaleName);
    }

    // Language and country codes
    String languageCode = platformLocaleName.substring(0, platformLocaleName.indexOf('_'));
    String countryCode = platformLocaleName.substring(platformLocaleName.indexOf('_') + 1);

    return Locale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
    );
  }
}

PlatformLocale getImplementation() => PlatformLocaleMobile();
