import 'package:studyu_designer_v2/pages/study_dashboard_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../router.dart';
import '../services/app_service.dart';
import '../services/auth_store.dart';
import '../theme.dart';

const isDebugMode = false;

class MyApp extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  final supabaseClient;

  const MyApp({
    Key? key,
    required this.sharedPreferences,
    required this.supabaseClient
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppDelegate appDelegate;
  late AuthService authService;

  final settings = ValueNotifier(ThemeSettings(
    //sourceColor: Color(0xff2a4fda),
    //sourceColor: Color(0xff583aee),
    sourceColor: const Color(0xff4845e5),
    themeMode: ThemeMode.system,
  ));


  @override
  void initState() {
    appDelegate = AppDelegate(widget.sharedPreferences);
    authService = AuthService(supabaseClient: widget.supabaseClient);
    authService.delegate = appDelegate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppDelegate>(create: (_) => appDelegate),
          Provider<AppRouter>(create: (_) => AppRouter(appDelegate: appDelegate)),
          Provider<AuthService>(create: (_) => authService),
        ],
        child: DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) => ThemeProvider(
              lightDynamic: lightDynamic,
              darkDynamic: darkDynamic,
              settings: settings,
              child: Builder(
                builder: (context) {
                  final themeProvider = ThemeProvider.of(context);
                  final appTheme = themeProvider.light(settings.value.sourceColor);
                  final appRouter = Provider.of<AppRouter>(context, listen: false).router;

                  return MaterialApp.router(
                    debugShowCheckedModeBanner: isDebugMode,
                    title: 'StudyU Designer V2',
                    color: appTheme.colorScheme.surface,
                    theme: appTheme,
                    routeInformationParser: appRouter.routeInformationParser,
                    routerDelegate: appRouter.routerDelegate,
                  );
                  /*
                  return MaterialApp(
                    debugShowCheckedModeBanner: isDebugMode,
                    title: 'StudyU Designer',
                    theme: appTheme.light(settings.value.sourceColor),
                    home: const StudyDashboardScreen(),
                  );*/
                }
              )
            )
        )
    );
  }
}