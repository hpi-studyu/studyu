import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';
import 'package:supabase/supabase.dart' show SupabaseClient;

import 'models/app_state.dart';
import 'router.dart';
import 'theme.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppState _appState;

  RootRouterDelegate _rootRouterDelegate;
  RootRouteInformationParser _rootRouteInformationParser;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _rootRouterDelegate = RootRouterDelegate(_appState);
    _rootRouteInformationParser = RootRouteInformationParser();
  }

  static const supabaseUrl = 'https://urrbcqpjcgokldetihiw.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYxNzUzMDYwMSwiZXhwIjoxOTMzMTA2NjAxfQ.T-QhpPisubwjOn3P1Gj3DV-2Mb_ztzvLwiVYWrGFvVA';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>(create: (context) => AppLanguage(AppLocalizations.supportedLocales)),
        ChangeNotifierProvider<AppState>.value(value: _appState),
        Provider<SupabaseClient>(create: (_) => SupabaseClient(supabaseUrl, supabaseAnonKey)),
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp.router(
          title: 'StudyU Designer',
          theme: theme,
          routerDelegate: _rootRouterDelegate,
          routeInformationParser: _rootRouteInformationParser,
          locale: model.appLocal,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => child,
        );
      }),
    );
  }
}
