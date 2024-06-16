import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'locale_providers.dart';

part 'locale_state.g.dart';

Locale fallbackLocale = Locale(Config.defaultLocale.first, Config.defaultLocale.last);

@immutable
class LocaleState {
  const LocaleState(this.locale);

  final Locale locale;

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale ?? this.locale);
  }
}

@riverpod
class LocaleStateNotifier extends _$LocaleStateNotifier {
  @override
  LocaleState build() {
    /// Initialize Locale
    /// Can be run at startup to establish the initial local from storage, or the platform
    /// 1. Attempts to restore locale from storage
    /// 2. IF no locale in storage, attempts to set local from the platform settings
    // Attempt to restore from storage
    final bool fromStorageSuccess = restoreFromStorage();

    // TODO MERGE
    // If storage restore did not work, set from platform
    if (!fromStorageSuccess) {
      setLocale(ref.read(platformLocaleProvider));
    }
    return LocaleState(fallbackLocale);
  }

  static const _localStorageKey = 'lang';

  /// Set Locale
  /// Attempts to set the locale if it's in our list of supported locales.
  /// IF NOT: get the first locale that matches our language code and set that
  /// ELSE: do nothing.
  void setLocale(Locale locale) async {
    final List<Locale> supportedLocales = ref.watch(supportedLocalesProvider);

    // Set the locale if it's in our list of supported locales
    if (supportedLocales.contains(locale)) {
      state = state.copyWith(locale: locale);
      // TODO MERGE
      // save();
    }

    // Get the closest language locale and set that instead
    Locale? closestLocale;
    for (final Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        closestLocale = supportedLocale;
      }
    }
    if (closestLocale != null) {
      state = state.copyWith(locale: closestLocale);
      save();
    }
  }

  /// Restore Locale from Storage
  Future<bool> restoreFromStorage() async {
    // TODO MERGE
    return (await load()) != null;
    /*try {
      LocaleState? loadedState = await load();
      if (loadedState != null) {
        state = loadedState;
        return true;
      }
    } catch (e) {
      rethrow;
    }
    // If storage restore did not work, set from platform
    setLocale(ref.watch(platformLocaleProvider));
    return false;*/
  }

  Future<LocaleState?> load() async {
    try {
      final String? locString = await SecureStorage.read(_localStorageKey);
      if (locString != null) {
        final locale = locString.split('-');
        return LocaleState(Locale(locale.first, locale.last));
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> save() async {
    SecureStorage.write(_localStorageKey, state.locale.toLanguageTag());
  }
}
