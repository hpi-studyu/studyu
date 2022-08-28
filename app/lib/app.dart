import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'models/app_state.dart';
import 'routes.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  const MyApp(this.queryParameters);
  final Map<String, String> queryParameters;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
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
        ChangeNotifierProvider<AppLanguage>(create: (context) => AppLanguage(AppLocalizations.supportedLocales)),
        ChangeNotifierProvider<AppState>(create: (context) => AppState(context)),
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
          );
        },
      ),
    );
  }
}
