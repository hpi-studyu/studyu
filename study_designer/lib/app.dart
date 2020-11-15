import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyou_core/util/parse_init.dart';

import 'dashboard.dart';
import 'designer.dart';
import 'routes.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLanguage appLanguage;

  final routes = {
    designerRoute: (_) => Designer(route: designerRoute),
    homeRoute: (_) => ParseInit(child: Dashboard()),
  };

  @override
  void initState() {
    super.initState();
    appLanguage = AppLanguage()..fetchLocale();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>.value(
      value: appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          title: 'StudyU Designer',
          theme: theme,
          onGenerateRoute: (settings) {
            if (settings.name.startsWith(designerRoute)) {
              return MaterialPageRoute(builder: (_) => Designer(route: settings.name), settings: settings);
            }
            // Go back to home, if route not found
            if (!routes.containsKey(settings.name)) {
              return MaterialPageRoute(builder: routes[homeRoute]);
            }
            return MaterialPageRoute(builder: routes[settings.name], settings: settings);
          },
          locale: model.appLocal,
          supportedLocales: AppLanguage.supportedLocales,
          localizationsDelegates: [
            Nof1Localizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
        );
      }),
    );
  }
}
