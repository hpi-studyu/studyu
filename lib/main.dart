import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'dashboard/dashboard.dart';
import 'util/localization.dart';
import 'welcome/about.dart';
import 'welcome/study_selection.dart';
import 'welcome/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
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
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: "/welcome",
          routes: <String, WidgetBuilder>{
            "/welcome": (context) => WelcomeScreen(),
            "/about": (context) => AboutScreen(),
            "/studySelection": (context) => StudySelectionScreen(),
            "/dashboard": (context) => DashboardScreen(),
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
