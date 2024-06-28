import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/locale_state.dart';
import 'package:studyu_designer_v2/localization/platform_locale/platform_locale_interface.dart';

/// Platform Locale Provider
/// Returns the locale of the Platform.localeName
final platformLocaleProvider = Provider<Locale>((_) {
  // Get the platform language using platform specific implementations
  final Locale platformLocale = PlatformLocale().getPlatformLocale();

  return platformLocale;
});

/// Supported Locales Provider
final supportedLocalesProvider = Provider<List<Locale>>((_) {
  return Config.supportedLocales.entries
      .map((e) => Locale(e.key, e.value))
      .toList();
});

/// Locale Provider
/// Provides the current locale, and automatically updates when the locale changes.
final localeProvider = Provider<Locale>((ref) {
  return ref.watch(localeStateProvider).locale;
});

final localeStateProvider =
    StateNotifierProvider<LocaleStateNotifier, LocaleState>(
  (ref) => LocaleStateNotifier(ref),
);
