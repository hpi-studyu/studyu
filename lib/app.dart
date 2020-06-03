import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';

import 'dashboard/dashboard.dart';
import 'environments/environment.dart';
import 'theme.dart';
import 'util/localization.dart';
import 'welcome/about.dart';
import 'welcome/study_selection.dart';
import 'welcome/welcome.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLanguage appLanguage;

  @override
  void initState() {
    super.initState();
    initLanguage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initParse(Environment.of(context));
  }

  void initLanguage() {
    appLanguage = AppLanguage();
    appLanguage.fetchLocale();
  }

  void initParse(Environment env) async {
    if (!Parse().hasParseBeenInitialized()) {
      await Parse().initialize(env.keyParseApplicationId, env.keyParseServerUrl,
          masterKey: env.keyParseMasterKey, debug: env.debug, coreStore: await CoreStoreSharedPrefsImp.getInstance());
      final response = await Parse().healthCheck();
      if (response.success) {
        print('Connection to Parse server successful');
      } else {
        print('Failed establishing connection to Parse server');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>.value(
      value: appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          title: 'Nof1 Initial app',
          theme: theme,
          initialRoute: '/welcome',
          routes: <String, WidgetBuilder>{
            '/welcome': (context) => WelcomeScreen(),
            '/about': (context) => AboutScreen(),
            '/studySelection': (context) => StudySelectionScreen(),
            DashboardScreen.routeName: (context) => DashboardScreen(),
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
