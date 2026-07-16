import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/main.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

String browserTitleForPath(String path, AppLocalizations l10n) =>
    switch (path) {
      '/${RouteNames.welcome}' ||
      '/${RouteNames.onboarding}' => l10n.onboarding_page0_title,
      '/${RouteNames.terms}' => l10n.terms,
      '/${RouteNames.studySelection}' => l10n.study_selection,
      '/${RouteNames.studyOverview}' => l10n.study_overview_title,
      '/${RouteNames.eligibilityCheck}' => l10n.eligibility_questionnaire_title,
      '/${RouteNames.interventionSelection}' =>
        l10n.intervention_selection_title,
      '/${RouteNames.journey}' => l10n.your_journey,
      '/${RouteNames.consent}' => l10n.consent,
      _ => 'StudyU',
    };

class MyApp extends StatefulWidget {
  const MyApp(
    this.queryParameters,
    this.appConfig, {
    super.key,
    required this.initialRoute,
  });
  final Map<String, String> queryParameters;
  final AppConfig? appConfig;
  final String initialRoute;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      queryParameters: widget.queryParameters,
      initialLocation: widget.initialRoute,
      navigatorKey: navigatorKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>(
          create: (context) => AppLanguage(AppLocalizations.supportedLocales),
        ),
        ChangeNotifierProvider<AppState>(create: (context) => AppState()),
      ],
      child: Consumer<AppLanguage>(
        builder: (context, model, child) {
          return ListenableBuilder(
            listenable: _router.routeInformationProvider,
            builder: (context, child) => MaterialApp.router(
              onGenerateTitle: (context) => browserTitleForPath(
                _router.routeInformationProvider.value.uri.path,
                AppLocalizations.of(context)!,
              ),
              theme: theme,
              routerConfig: _router,
              localeListResolutionCallback: (locales, supportedLocales) {
                // print('device locales=$locales supported locales=$supportedLocales');
                final supportedLanguageCodes = supportedLocales.map(
                  (e) => e.languageCode,
                );
                if (locales != null) {
                  for (final locale in locales) {
                    if (supportedLanguageCodes.contains(locale.languageCode)) {
                      return locale;
                    }
                  }
                }
                return const Locale('en');
              },
              locale: model.appLocal,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
            ),
          );
        },
      ),
    );
  }
}
