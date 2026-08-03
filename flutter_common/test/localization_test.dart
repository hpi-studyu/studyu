import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/src/utils/localization.dart';

void main() {
  group('AppLanguage', () {
    tearDown(() {
      AppLanguage.debugResetHasAuthenticatedUserForTesting();
      AppLanguage.debugResetLocalLanguageReaderForTesting();
      AppLanguage.debugResetLocalLanguageWriterForTesting();
      AppLanguage.debugResetLocalLanguageClearerForTesting();
      AppLanguage.debugResetCurrentUserLoaderForTesting();
      AppLanguage.debugResetLanguageSaverForTesting();
    });

    test(
      'hydrates signed-in language from server after local fallback',
      () async {
        String? localLanguage = 'en';

        AppLanguage.debugHasAuthenticatedUserForTesting = () => true;
        AppLanguage.debugLocalLanguageReaderForTesting = () async =>
            localLanguage;
        AppLanguage.debugLocalLanguageWriterForTesting = (value) async {
          localLanguage = value;
        };
        AppLanguage.debugCurrentUserLoaderForTesting = () async => StudyUUser(
          id: 'user-1',
          email: 'user@test.local',
          preferences: Preferences(language: 'de'),
        );

        final language = AppLanguage(const [Locale('en'), Locale('de')]);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(language.appLocal?.languageCode, 'de');
        expect(localLanguage, 'de');
      },
    );

    test('persists language remotely when signed in', () async {
      final savedLanguages = <String>[];
      String? localLanguage;

      AppLanguage.debugHasAuthenticatedUserForTesting = () => true;
      AppLanguage.debugLocalLanguageReaderForTesting = () async => null;
      AppLanguage.debugLocalLanguageWriterForTesting = (value) async {
        localLanguage = value;
      };
      AppLanguage.debugCurrentUserLoaderForTesting = () async =>
          StudyUUser(id: 'user-1', email: 'user@test.local');
      AppLanguage.debugLanguageSaverForTesting = (value) async {
        savedLanguages.add(value);
      };

      final language = AppLanguage(const [Locale('en'), Locale('de')]);
      await Future<void>.delayed(Duration.zero);

      await language.changeLanguage(const Locale('de'));

      expect(language.appLocal?.languageCode, 'de');
      expect(localLanguage, 'de');
      expect(savedLanguages, ['de']);
    });
  });
}
