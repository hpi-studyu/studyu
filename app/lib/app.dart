import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'main.dart';
import 'models/app_state.dart';
import 'routes.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  const MyApp(this.queryParameters, {Key key}) : super(key: key);
  final Map<String, String> queryParameters;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    print("app.init");
  }

  @override
  Widget build(BuildContext context) {
    print("app.build");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>(create: (context) => AppLanguage(AppLocalizations.supportedLocales)),
        ChangeNotifierProvider<AppState>(create: (context) => AppState()),
      ],
      child: Consumer<AppLanguage>(
        builder: (context, model, child) {
          return MaterialApp(
            title: 'StudyU',
            theme: theme,
            initialRoute: Routes.loading,
            onGenerateRoute: (RouteSettings settings) {
              return Routes.generateRoute(settings, widget.queryParameters);
            },
            onUnknownRoute: Routes.unknownRoute,
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
