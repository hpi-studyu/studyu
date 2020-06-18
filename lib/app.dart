import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/daos/study_dao.dart';
import 'database/models/study_instance.dart';
import 'environments/environment.dart';
import 'routes.dart';
import 'study_onboarding/app_state.dart';
import 'theme.dart';
import 'util/localization.dart';
import 'util/user.dart';

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
    initLanguage();
    initStudy();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initParse(Environment.of(context));
  }

  void initLanguage() {
    appLanguage = AppLanguage()..fetchLocale();
  }

  Future<void> initStudy() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedStudyObjectId = prefs.getString(UserUtils.selectedStudyObjectIdKey);
    selectedStudy = await StudyDao.getUserStudy(selectedStudyObjectId);
  }

  Future<void> initParse(Environment env) async {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>.value(value: appLanguage),
        Provider<AppModel>(create: (context) => AppModel(selectedStudy)),
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          title: 'Nof1 Initial app',
          theme: theme,
          initialRoute: Routes.welcome,
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
