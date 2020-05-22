import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';

import 'dashboard/dashboard.dart';
import 'theme.dart';
import 'util/localization.dart';
import 'welcome/about.dart';
import 'welcome/study_selection.dart';
import 'welcome/welcome.dart';

const keyParseApplicationId = 'nof1';
const keyParseServerUrl = 'https://nof1.herokuapp.com/parse';
const keyParseMasterKey = '2d?xz*63GyZ4nDKp#WPKL5?5HLE=dDKm+epsA%Bp';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  await Parse().initialize(keyParseApplicationId, keyParseServerUrl,
      masterKey: keyParseMasterKey, debug: true, coreStore: await CoreStoreSharedPrefsImp.getInstance());
  final response = await Parse().healthCheck();
  if (response.success) {
    print('Connection to Parse server successful');
  } else {
    print("Failed establishing connection to Parse server");
  }

  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

class MyApp extends StatelessWidget {
  final AppLanguage appLanguage;

  MyApp({this.appLanguage});

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
            '/dashboard': (context) => DashboardScreen(),
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
