// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$platformLocaleHash() => r'e490bf2439a27d6a6ca15f4029f5b198fd6817ba';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlatformLocaleRef = AutoDisposeProviderRef<Locale>;
String _$supportedLocalesHash() => r'9cd4634b71b66c5e97b66ecbfd966d91eecfcc64';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupportedLocalesRef = AutoDisposeProviderRef<List<Locale>>;
String _$localeHash() => r'9b088ff7f2fc32aeeeb72d3c9d8a37abddb9757e';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocaleRef = AutoDisposeProviderRef<Locale>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
