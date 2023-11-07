import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:studyu_app/util/app_analytics.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'main.dart';
import 'models/app_state.dart';
import 'routes.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  const MyApp(this.queryParameters, this.appConfig, {super.key});
  final Map<String, String> queryParameters;
  final AppConfig? appConfig;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>(create: (context) => AppLanguage(AppLocalizations.supportedLocales)),
        ChangeNotifierProvider<AppState>(create: (context) => AppState(widget.appConfig)),
      ],
      child: Consumer<AppLanguage>(
        builder: (context, model, child) {
          context.read<AppState>().analytics = AppAnalytics(context);
          return MaterialApp(
            title: 'StudyU',
            theme: theme,
            initialRoute: Routes.loading,
            onGenerateRoute: (RouteSettings settings) {
              return Routes.generateRoute(settings, widget.queryParameters);
            },
            onUnknownRoute: Routes.unknownRoute,
            navigatorObservers: [
              SentryNavigatorObserver(),
            ],
            localeListResolutionCallback: (locales, supportedLocales) {
              // print('device locales=$locales supported locales=$supportedLocales');
              final supportedLanguageCodes = supportedLocales.map((e) => e.languageCode);
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
            navigatorKey: navigatorKey,
          );
        },
      ),
    );
  }
}
