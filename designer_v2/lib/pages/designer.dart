import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../router.dart';
import '../services/app_service.dart';
import '../services/auth_store.dart';

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class Designer extends ConsumerWidget {

  const Designer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDelegate appDelegate;
    final AuthService authService;
    appDelegate = AppDelegate(ref.watch(sharedPreferencesProvider));

    // todo Is delegate necessary with riverpod?
    authService = AuthService();
    authService.delegate = appDelegate;

    final router = ref.watch(routerProvider);

    // TODO Include theme into current implementation
    /*
      final settings = ValueNotifier(ThemeSettings(
    //sourceColor: Color(0xff2a4fda),
    //sourceColor: Color(0xff583aee),
    sourceColor: const Color(0xff4845e5),
    themeMode: ThemeMode.system,
    ));
    final theme = ThemeProvider.of(context);
    return DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => ThemeProvider(
            lightDynamic: lightDynamic,
            darkDynamic: darkDynamic,
            settings: settings,
            child: Builder(builder: (context) {
              final themeProvider = ThemeProvider.of(context);
              final appTheme = themeProvider.light(settings.value.sourceColor);
              //final appRouter = Provider.of<AppRouter>(context, listen: false).router;
              //final appRouter = context.read<AppRouter>().router;
    */
    return MaterialApp.router(
      debugShowCheckedModeBanner: kDebugMode,
      title: 'StudyU Designer V2',
      //color: appTheme.colorScheme.surface,
      //theme: appTheme,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
    /*
    return MaterialApp(
      debugShowCheckedModeBanner: isDebugMode,
      title: 'StudyU Designer',
      theme: appTheme.light(settings.value.sourceColor),
      home: const StudyDashboardScreen(),
    );*/
  }
}
