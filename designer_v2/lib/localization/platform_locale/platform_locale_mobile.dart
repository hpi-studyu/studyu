import 'dart:io';
import 'dart:ui';

import 'platform_locale_interface.dart';

class PlatformLocaleMobile implements PlatformLocale {
  @override
  Locale getPlatformLocale() {
    String _platformLocaleName = Platform.localeName;
    print("Platform Locale Name (Mobile): " + _platformLocaleName);

    // Language code only
    if (_platformLocaleName.length == 2) {
      return Locale.fromSubtags(languageCode: _platformLocaleName);
    }

    // Language and country codes
    String _languageCode = _platformLocaleName.substring(0, _platformLocaleName.indexOf('_'));
    String _countryCode = _platformLocaleName.substring(_platformLocaleName.indexOf('_') + 1);

    return Locale.fromSubtags(
      languageCode: _languageCode,
      countryCode: _countryCode,
    );
  }
}

PlatformLocale getImplementation() => PlatformLocaleMobile();