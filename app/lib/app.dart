import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'models/app_state.dart';
import 'routes.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLanguage appLanguage;
  ParseUserStudy selectedStudy;

  @override
  void initState() {
    super.initState();
    appLanguage = AppLanguage()..fetchLocale();
    if (!kIsWeb) {
      _configureLocalTimeZone();
    }
  }

  /// This is needed for flutter_local_notifications
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>.value(value: appLanguage),
        Provider<AppState>(create: (context) => AppState(selectedStudy)),
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          title: 'StudyU',
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
