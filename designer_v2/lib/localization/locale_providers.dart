import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/platform_locale/platform_locale_interface.dart';

import 'locale_state.dart';

part 'locale_providers.g.dart';

/// Platform Locale Provider
/// Returns the locale of the Platform.localeName
@riverpod
Locale platformLocale(PlatformLocaleRef ref) {
  // Get the platform language using platform specific implementations
  return PlatformLocale().getPlatformLocale();
}

/// Supported Locales Provider
@riverpod
List<Locale> supportedLocales(SupportedLocalesRef ref) {
  return Config.supportedLocales.entries.map((e) => Locale(e.key, e.value)).toList();
}

/// Locale Provider
/// Provides the current locale, and automatically updates when the locale changes.
@riverpod
Locale locale(LocaleRef ref) {
  return ref.watch(localeStateNotifierProvider).locale;
}
