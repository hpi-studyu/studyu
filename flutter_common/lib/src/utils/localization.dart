import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/src/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppLanguage extends ChangeNotifier {
  static const String keyLanguageCode = 'language_code';
  final List<Locale> supportedLocales;
  Locale? _appLocale;
  static bool Function() _hasAuthenticatedUser = _defaultHasAuthenticatedUser;
  static Future<String?> Function() _localLanguageReader = _readLocalLanguage;
  static Future<void> Function(String) _localLanguageWriter =
      _writeLocalLanguage;
  static Future<void> Function() _localLanguageClearer = _clearLocalLanguage;
  static Future<StudyUUser?> Function() _currentUserLoader =
      _loadCurrentUserFromServer;
  static Future<void> Function(String) _languageSaver = _saveLanguageToServer;

  AppLanguage(this.supportedLocales) : super() {
    fetchLocale();
  }

  Locale? get appLocal => _appLocale;

  Future<void> fetchLocale() async {
    final languageCode = await _localLanguageReader();
    _appLocale = _resolveSupportedLocale(languageCode);
    notifyListeners();
    await syncWithAuthenticatedUser();
  }

  Future<void> changeLanguage(Locale? locale) async {
    if (_appLocale == locale) return;
    if (locale == null || !supportedLocales.contains(locale)) {
      _appLocale = null;
      await _localLanguageClearer();
    } else {
      _appLocale = locale;
      await _localLanguageWriter(locale.languageCode);
    }

    if (_hasAuthenticatedUser()) {
      try {
        await _languageSaver(_appLocale?.languageCode ?? '');
      } catch (e) {
        StudyULogger.warning('Failed to persist app language on server: $e');
      }
    }

    notifyListeners();
  }

  Future<void> syncWithAuthenticatedUser() async {
    if (!_hasAuthenticatedUser()) return;

    try {
      final user = await _currentUserLoader();
      final remoteLocale = _resolveSupportedLocale(user?.preferences.language);
      if (remoteLocale == null || _appLocale == remoteLocale) return;

      _appLocale = remoteLocale;
      await _localLanguageWriter(remoteLocale.languageCode);
      notifyListeners();
    } catch (e) {
      StudyULogger.warning('Failed to hydrate app language from server: $e');
    }
  }

  Locale? _resolveSupportedLocale(String? languageCode) {
    final normalized = languageCode?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;

    for (final locale in supportedLocales) {
      if (locale.toLanguageTag().toLowerCase() == normalized ||
          locale.languageCode.toLowerCase() == normalized) {
        return locale;
      }
    }
    return null;
  }

  static Future<StudyUUser?> _loadCurrentUserFromServer() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;
    return await SupabaseQuery.getById<StudyUUser>(userId);
  }

  static Future<void> _saveLanguageToServer(String languageCode) async {
    final user = await _loadCurrentUserFromServer();
    if (user == null) return;
    user.preferences.language = languageCode;
    await user.save(onlyUpdate: true);
  }

  static Future<String?> _readLocalLanguage() async {
    return await SecureStorage.read(keyLanguageCode);
  }

  static bool _defaultHasAuthenticatedUser() {
    return Supabase.instance.client.auth.currentUser != null;
  }

  static Future<void> _writeLocalLanguage(String languageCode) async {
    await SecureStorage.write(keyLanguageCode, languageCode);
  }

  static Future<void> _clearLocalLanguage() async {
    await SecureStorage.delete(keyLanguageCode);
  }

  @visibleForTesting
  static bool Function() get debugHasAuthenticatedUserForTesting =>
      _hasAuthenticatedUser;

  @visibleForTesting
  static set debugHasAuthenticatedUserForTesting(bool Function() checker) {
    _hasAuthenticatedUser = checker;
  }

  @visibleForTesting
  static void debugResetHasAuthenticatedUserForTesting() {
    _hasAuthenticatedUser = _defaultHasAuthenticatedUser;
  }

  @visibleForTesting
  static Future<String?> Function() get debugLocalLanguageReaderForTesting =>
      _localLanguageReader;

  @visibleForTesting
  static set debugLocalLanguageReaderForTesting(
    Future<String?> Function() reader,
  ) {
    _localLanguageReader = reader;
  }

  @visibleForTesting
  static void debugResetLocalLanguageReaderForTesting() {
    _localLanguageReader = _readLocalLanguage;
  }

  @visibleForTesting
  static Future<void> Function(String) get debugLocalLanguageWriterForTesting =>
      _localLanguageWriter;

  @visibleForTesting
  static set debugLocalLanguageWriterForTesting(
    Future<void> Function(String) writer,
  ) {
    _localLanguageWriter = writer;
  }

  @visibleForTesting
  static void debugResetLocalLanguageWriterForTesting() {
    _localLanguageWriter = _writeLocalLanguage;
  }

  @visibleForTesting
  static Future<void> Function() get debugLocalLanguageClearerForTesting =>
      _localLanguageClearer;

  @visibleForTesting
  static set debugLocalLanguageClearerForTesting(
    Future<void> Function() clearer,
  ) {
    _localLanguageClearer = clearer;
  }

  @visibleForTesting
  static void debugResetLocalLanguageClearerForTesting() {
    _localLanguageClearer = _clearLocalLanguage;
  }

  @visibleForTesting
  static Future<StudyUUser?> Function() get debugCurrentUserLoaderForTesting =>
      _currentUserLoader;

  @visibleForTesting
  static set debugCurrentUserLoaderForTesting(
    Future<StudyUUser?> Function() loader,
  ) {
    _currentUserLoader = loader;
  }

  @visibleForTesting
  static void debugResetCurrentUserLoaderForTesting() {
    _currentUserLoader = _loadCurrentUserFromServer;
  }

  @visibleForTesting
  static Future<void> Function(String) get debugLanguageSaverForTesting =>
      _languageSaver;

  @visibleForTesting
  static set debugLanguageSaverForTesting(Future<void> Function(String) saver) {
    _languageSaver = saver;
  }

  @visibleForTesting
  static void debugResetLanguageSaverForTesting() {
    _languageSaver = _saveLanguageToServer;
  }
}
