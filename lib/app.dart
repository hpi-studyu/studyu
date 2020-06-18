import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'database/models/study_instance.dart';
import 'routes.dart';
import 'study_onboarding/app_state.dart';
import 'theme.dart';
import 'util/localization.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLanguage appLanguage;
  StudyInstance selectedStudy;

  @override
  void initState() {
    super.initState();
    appLanguage = AppLanguage()..fetchLocale();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>.value(value: appLanguage),
        Provider<AppModel>(create: (context) => AppModel(selectedStudy)),
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          title: 'Nof1 Initial app',
          theme: theme,
          initialRoute: Routes.loading,
          onGenerateRoute: Routes.generateRoute,
          onUnknownRoute: Routes.unknownRoute,
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
