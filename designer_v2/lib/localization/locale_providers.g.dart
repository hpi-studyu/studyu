// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$platformLocaleHash() => r'a84e9e99af5cc228a9c3804c7b4b834044dff6d1';

/// Platform Locale Provider
/// Returns the locale of the Platform.localeName
///
/// Copied from [platformLocale].
@ProviderFor(platformLocale)
final platformLocaleProvider = AutoDisposeProvider<Locale>.internal(
  platformLocale,
  name: r'platformLocaleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$platformLocaleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PlatformLocaleRef = AutoDisposeProviderRef<Locale>;
String _$supportedLocalesHash() => r'5668fd6c2cb7ae6ce48a909d39d947d6ee61236a';

/// Supported Locales Provider
///
/// Copied from [supportedLocales].
@ProviderFor(supportedLocales)
final supportedLocalesProvider = AutoDisposeProvider<List<Locale>>.internal(
  supportedLocales,
  name: r'supportedLocalesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supportedLocalesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SupportedLocalesRef = AutoDisposeProviderRef<List<Locale>>;
String _$localeHash() => r'575c8d69cac8ac079fbb4a4d4b2307512dcfc728';

/// Locale Provider
/// Provides the current locale, and automatically updates when the locale changes.
///
/// Copied from [locale].
@ProviderFor(locale)
final localeProvider = AutoDisposeProvider<Locale>.internal(
  locale,
  name: r'localeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$localeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LocaleRef = AutoDisposeProviderRef<Locale>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
